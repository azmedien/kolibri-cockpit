# Be sure to restart your server when you modify this file.

# ApplicationController.renderer.defaults.merge!(
#   http_host: 'example.org',
#   https: false
# )

require "git"

Git.configure do |config|
  config.git_ssh = Rails.root.join('ssh-git.sh').to_s
end
