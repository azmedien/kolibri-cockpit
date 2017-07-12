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

  def perform(app, platform, user)

    send_cable('Configure the app...', 'notice')

    begin
      if platform == 'android'
        perform_android app, user
      elsif platform == 'ios'
        perform_ios app, user
      else
        perform_android app, user
        perform_ios app, user
      end
    rescue Exception => e
      send_cable("<h4 class='alert-heading'>Cannot configure the app.</h4> <p>#{e.message}</p>", 'danger')
      raise
    end

    send_cable("<h4 class='alert-heading'>The application is configured.</h4> <p>Shortly Jenkins will start publishing it and status indicator will appear below.</p>", 'warning')
  end

  private

  def perform_android(app, user)
    repo = app.android_config['repository_url']
    bundle = app.android_config['bundle_id']

    return if repo.nil? || repo.empty? || bundle.nil? || bundle.empty?

    open_repo repo

    manipulate_repo repo, app, user do |_git|
      modify_android_configuration_files '.', app
      setup_android_title '.', app
      copy_android_assets '.', app
      copy_android_firebase '.', app
    end
  end

  def perform_ios(app, user)
    repo = app.ios_config['repository_url']
    bundle = app.ios_config['bundle_id']

    return if repo.nil? || repo.empty? || bundle.nil? || bundle.empty?

    open_repo repo

    manipulate_repo repo, app, user do |_git|
      modify_ios_configuration_files '.', app
      copy_ios_assets '.', app
      copy_ios_firebase '.', app
    end
  end
end
