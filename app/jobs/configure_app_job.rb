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

  # TODO: Refactor me.
  def perform(app, user)
    repo = app.android_config['repository_url']
    bundle = app.android_config['bundle_id']

    if repo.nil? || repo.empty? || bundle.nil? || bundle.empty?
      return
    end

    open_repo repo

    manipulate_repo repo, app, user do |git|
      modify_android_configuration_files '.', app
      setup_android_title '.', app
      copy_android_assets '.', app
    end

    repo = app.ios_config['repository_url']
    bundle = app.ios_config['bundle_id']

    if repo.nil? || repo.empty? || bundle.nil? || bundle.empty?
      return
    end

    open_repo repo

    manipulate_repo repo, app, user do |git|
      modify_ios_configuration_files '.', app
    end

    send_cable
  end
end
