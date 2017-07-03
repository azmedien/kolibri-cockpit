class ConfigureAppJob < ApplicationJob

  include GitHelper
  include ApplicationHelper
  include AppsHelper
  include AssetsHelper
  include UrlHelper

  queue_as :default

  rescue_from(StandardError) do |exception|
     logger.error exception.message
     logger.error exception.backtrace.join("\n")
  end

  # TODO: Refactor me.
  def perform(app, platform, user)
    if platform == 'android'
      perform_android app, user
    elsif platform == 'ios'
      perform_ios app, user
    else
      perform_android app, user
      perform_ios app, user
    end

    send_cable
  end

  private
  def perform_android app, user
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
      copy_anroid_firebase '.', app
    end
  end

  def perform_ios app, user
    repo = app.ios_config['repository_url']
    bundle = app.ios_config['bundle_id']

    if repo.nil? || repo.empty? || bundle.nil? || bundle.empty?
      return
    end

    open_repo repo

    manipulate_repo repo, app, user do |git|
      modify_ios_configuration_files '.', app
      copy_ios_assets '.', app
      copy_ios_firebase '.', app
    end
  end
end
