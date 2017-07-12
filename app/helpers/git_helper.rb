module GitHelper
  require 'uri'
  require 'git'

  def repo_exist?(reponame)
    File.directory?(Rails.root.join('tmp', reponame))
  end

  def clone_repo(url)
    folder = url.split('/').last
    Git.clone(url, folder, :path => Rails.root.join('tmp'), :log => Logger.new(STDOUT)) if !repo_exist?(folder)
  end

  def open_repo(url)
    folder = url.split('/').last
    clone_repo(url) if !repo_exist?(folder)
    git = Git.open(Rails.root.join('tmp', folder), :log => Logger.new(STDOUT))
    git.reset_hard()
    git.pull()

    git
  end

  def manipulate_repo(url, app, user)

    branch_name = app.internal_name.parameterize
    origin_app = App.friendly.find(app.android_config['origin']) if app.android_config['origin']

    repo = open_repo(url)
    repo_branches = repo.branches

    repo.config('user.name', "#{user.first_name} #{user.last_name}")
    repo.config('user.email', user.email)

    repo.checkout('master')

    # Trying to find origin app branch we want to branch from. We want to skip this if we alredy cloned the app
    if origin_app && (repo_branches[branch_name].nil? || repo_branches["origin/#{branch_name}"].nil?)
      origin_branch_name = origin_app.internal_name.parameterize
      # origin_branch = repo_branches["origin/#{origin_branch_name}"]
      repo.checkout(origin_branch_name) # Checkout the origin app branch so we will branch from it
      repo.pull()
    end

    repo.branch(branch_name).checkout

    begin
      repo.pull('origin', repo.branch(branch_name))
    rescue
    ensure
      begin
        repo.chdir do
          yield repo
          repo.add(:all=>true)
          repo.commit('Project configured by Kolibri Cockpit')
          repo.push('origin', app.internal_name.parameterize)
        end
       ensure
         repo.checkout('master')
         repo.branch(app.internal_name.parameterize).delete
       end
      end
    end
end
