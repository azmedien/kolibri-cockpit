# Be sure to restart your server when you modify this file.

# ActiveSupport::Reloader.to_prepare do
#   ApplicationController.renderer.defaults.merge!(
#     http_host: 'example.org',
#     https: false
#   )
# end

require 'git'

Git.configure do |config|
  config.git_ssh = Rails.root.join('ssh-git.sh').to_s
end
