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
    git.pull()

    git
  end

  def manipulate_repo(url, user)
    repo = open_repo(url)
    repo.checkout('master')
    repo.branch('new_branch').checkout

    begin
      repo.chdir do
        yield repo
      end
     ensure
       repo.config('user.name', 'Kolibri Cockpit')
       repo.config('user.email', user.email)

       repo.add(:all=>true)
       repo.commit('Project configured by Kolibri Cockpit')
       repo.push('origin', 'new_branch')
     end

     repo.checkout('master')
     repo.branch('new_branch').delete
  end
end
