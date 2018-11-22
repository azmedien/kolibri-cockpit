class ConfigureAppJob < ApplicationJob
  include GitHelper
  include ApplicationHelper
  include AssetsHelper

  queue_as :default

  rescue_from(StandardError) do |exception|
    logger.error exception.message
    logger.error exception.backtrace.join("\n")
  end

  def perform(app, params, user)

    @platform = params['platform'] || 'both'

    create_build app, @platform, user
    send_build_cable(@build)

    begin
      self.send("perform_#{@platform}", @build, params)

      send_build_update_cable(@build, 'waiting', 0, 'The application is configured. Soon Jenkins will start publishing...')
    rescue Exception => e
      send_cable("<h4 class='alert-heading'>Cannot configure the app.</h4> <pre>#{e.message}</pre>", 'danger')
      raise
    end
  end

  private
  def perform_android(build, params)
    repo = build.app.android_config['repository_url']
    bundle = build.app.android_config['bundle_id']

    raise "Repository must be set" if repo.nil? || repo.empty?
    raise "Application or Bundle Id must be set" if bundle.nil? || bundle.empty?

    tag_name = "#{build.app.internal_slug}-#{build.app.android_config['version_name']}"

    open_repo repo

    logger.tagged('Android') do
      manipulate_repo repo, build, tag_name do |_git|
        service = AppConfigureService.new('android', '.', build)
        service.configure_it params['channels']
      end
    end
  end

  def perform_ios(build, params)
    repo = build.app.ios_config['repository_url']
    bundle = build.app.ios_config['bundle_id']

    raise "Repository must be set" if repo.nil? || repo.empty?
    raise "Application or Bundle Id must be set" if bundle.nil? || bundle.empty?

    tag_name = "#{build.app.internal_slug}-#{build.app.ios_config['version_name']}"

    open_repo repo

    manipulate_repo repo, build, tag_name do |_git|
      service = AppConfigureService.new('ios', '.', build)
      service.configure_it params['channels']
    end
  end

  def perform_both(build, params)
    perform_android build, params
    perform_ios build, params
  end


  private
  def create_build(app, platform, user)
    @build = Build.new()
    @build.app = app
    @build.user = user
    @build.platform = platform
    @build.message = 'App will be configured now...'
    @build.stage = 'configure'
    @build.code = 0

    @build.save!
  end

end
