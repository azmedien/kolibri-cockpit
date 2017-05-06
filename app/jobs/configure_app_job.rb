class ConfigureAppJob < ApplicationJob

  include GitHelper
  include ApplicationHelper
  include AppsHelper
  include AssetsHelper
  include UrlHelper

  queue_as :default

  rescue_from(StandardError) do |exception|
     logger.fatal exception
  end

  def perform(app, user)
    repo = app.android_config['repository_url']
    bundle = app.android_config['bundle_id']

    open_repo repo

    manipulate_repo repo, user do |git|
      modify_android_configuration_files '.', app
    end

    send_cable
  end
end
