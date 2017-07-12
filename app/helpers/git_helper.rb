module GitHelper
  require 'uri'
  require 'git'

  def repo_exist?(reponame)
    File.directory?(Rails.root.join('tmp', reponame))
  end

  def clone_repo(url)
    folder = url.split('/').last
    Git.clone(url, folder, path: Rails.root.join('tmp'), log: Logger.new(STDOUT)) unless repo_exist?(folder)
  end

  def open_repo(url)
    folder = url.split('/').last
    clone_repo(url) unless repo_exist?(folder)
    git = Git.open(Rails.root.join('tmp', folder), log: Logger.new(STDOUT))
    git.checkout('master')
    git.reset_hard
    git.pull

    git
  end

  def manipulate_repo(url, app, user)
    branch_name = app.internal_name.parameterize
    origin_app = App.friendly.find(app.android_config['origin']) if app.android_config['origin']

    repo = open_repo(url)
    repo_branches = repo.branches

    repo.config('user.name', "#{user.first_name} #{user.last_name}")
    repo.config('user.email', user.email)

    # Trying to find origin app branch we want to branch from. We want to skip this if we alredy cloned the app
    if origin_app && (repo_branches[branch_name].nil? || repo_branches["origin/#{branch_name}"].nil?)
      origin_branch_name = origin_app.internal_name.parameterize

      if repo_branches[origin_branch_name]
        repo.checkout(origin_branch_name) # Checkout the origin app branch so we will branch from it
      end
    end

    repo.branch(branch_name).checkout

    if repo_branches["origin/#{branch_name}"]
      repo.pull('origin', repo.branch(branch_name))
    end

    begin
      repo.chdir do
        yield repo
        repo.add(all: true)
        repo.commit('Project configured by Kolibri Cockpit')
        repo.push('origin', branch_name)
      end
    ensure
      repo.checkout('master')
      repo.branch(branch_name).delete
    end
  end
end
