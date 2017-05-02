module GitHelper
  require 'uri'
  require 'git'

  def repo_exist?(reponame)
    File.directory?(Rails.root.join('tmp', reponame))
  end

  def clone_repo(url)
    folder = URI(url).path.split('/').last
    Git.clone(url, folder, :path => Rails.root.join('tmp'), :log => Logger.new(STDOUT)) if !repo_exist?(folder)
  end

  def open_repo(url)
    folder = URI(url).path.split('/').last
    clone_repo(url) if !repo_exist?(folder)
    Git.open(Rails.root.join('tmp', folder), :log => Logger.new(STDOUT))
  end

  def manipulate_repo(url)
    repo = open_repo(url)
    repo.checkout('master')

    begin
      repo.chdir do
        yield repo
      end
     ensure
       repo.add(:all=>true)
      #  repo.commit('Project configured by Kolibri Cockpit')
      #  repo.push
     end
  end
end
