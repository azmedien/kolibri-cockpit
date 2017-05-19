# Load the Rails application.
require_relative 'application'
require 'version'

# Initialize the Rails application.
Rails.application.initialize!

APP_VERSION = Version.current
