class ConfigureAppJob < ApplicationJob
  include GitHelper
  include ApplicationHelper
  include AssetsHelper

  queue_as :default

  rescue_from(StandardError) do |exception|
    logger.error exception.message
    logger.error exception.backtrace.join("\n")
  end

  def perform(app, platform, user)

    send_cable('Configure the app...', 'info')

    begin
      self.send("perform_#{platform}", app, user)
      send_cable("<h4 class='alert-heading'>The application is configured.</h4> <p>Shortly Jenkins will start publishing it and status indicator will appear below.</p>", 'warning')
    rescue Exception => e
      send_cable("<h4 class='alert-heading'>Cannot configure the app.</h4> <p>#{e.message}</p>", 'danger')
      raise
    end
  end

  private
  def perform_android(app, user)
    repo = app.android_config['repository_url']
    bundle = app.android_config['bundle_id']

    raise "Repository must be set" if repo.nil? || repo.empty?
    raise "Application or Bundle Id must be set" if bundle.nil? || bundle.empty?

    open_repo repo

    logger.tagged('Android') do
      manipulate_repo repo, app, user do |_git|
        service = AppConfigureService.new('android', '.', app)
        service.configure_it
        _git.add_tag("#{app.internal_name.parameterize}-#{app.android_config[version_name]}(#{app.android_config[version_code]})")
        _git.push
      end
    end
  end

  def perform_ios(app, user)
    repo = app.ios_config['repository_url']
    bundle = app.ios_config['bundle_id']

    raise "Repository must be set" if repo.nil? || repo.empty?
    raise "Application or Bundle Id must be set" if bundle.nil? || bundle.empty?

    open_repo repo

    manipulate_repo repo, app, user do |_git|
      service = AppConfigureService.new('ios', '.', app)
      service.configure_it
      _git.add_tag("#{app.internal_name.parameterize}-#{app.ios_config[version_name]}(#{app.ios_config[version_code]})")
      _git.push
    end
  end

  def platform_both(app, user)
    perform_android app, user
    perform_ios app, user
  end
end
