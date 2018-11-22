module GitHelper
  require 'uri'
  require 'git'

  include WebhooksHelper

  def repo_exist?(reponame)
    File.directory?(Rails.root.join('tmp', reponame))
  end

  def clone_repo(url)
    folder = url.split('/').last
    Git.clone(url, folder, path: Rails.root.join('tmp'), log: Logger.new(STDOUT, level: :info)) unless repo_exist?(folder)
  end

  def open_repo(url)
    folder = url.split('/').last
    clone_repo(url) unless repo_exist?(folder)
    git = Git.open(Rails.root.join('tmp', folder), log: Logger.new(STDOUT, level: :info))
    git.reset_hard
    git.clean(force: true, d: true)
    git.checkout('master')
    git.pull

    git
  end

  def manipulate_repo(url, build, tag)
    @build = build

    send_build_update_cable(@build, 'git', 0, 'Checkout...')
    branch_name = build.app.internal_slug
    origin_app = App.friendly.find(build.app.android_config['origin']) if build.app.android_config['origin']
    begin
      repo = open_repo(url)
      repo_branches = repo.branches

      repo.config('user.name', "#{build.user.first_name} #{build.user.last_name}")
      repo.config('user.email', build.user.email)

      # Trying to find origin app branch we want to branch from. We want to skip this if we alredy cloned the app
      if origin_app && (repo_branches[branch_name].nil? || repo_branches["origin/#{branch_name}"].nil?)
        origin_branch_name = origin_app.internal_slug

        if repo_branches[origin_branch_name] || repo_branches["origin/#{origin_branch_name}"]
          repo.checkout(origin_branch_name) # Checkout the origin app branch so we will branch from it
        end
      end

      if repo_branches["origin/#{branch_name}"]
        repo.checkout(branch_name)
        repo.pull('origin', branch_name) if repo_branches["origin/#{branch_name}"]
      else
        repo.branch(branch_name).checkout
      end

      repo.chdir do
        yield repo
        repo.add(all: true)
        repo.commit('Project configured by Kolibri Cockpit')
        repo.push('origin', branch_name)

        if tag
          repo.add_tag(tag)
          repo.push('origin', "refs/tags/#{tag}")
        end
      end
    rescue Exception => e
      send_build_update_cable(@build, 'git', -1, 'Error: No new changes to the app or fatal git error. Make sure you made changes since last build or contanct administrator.')
      logger.error e.message
      logger.error e.backtrace.join("\n")
      raise
    ensure
      repo.reset_hard
      repo.clean(force: true, d: true)
      repo.checkout('master')
      repo.branch(branch_name).delete
    end
  end
end
