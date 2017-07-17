class AppConfigureService
  attr_reader :platform_instance, :folder, :app

  def initialize(platform, folder, app)
    @platform_instance = "#{platform.capitalize}ConfigureService".constantize.new(folder, app)
  end

  def configure_firebase
    @platform_instance.configure_firebase
  end

  def configure_fastlane
    @platform_instance.configure_fastlane
  end

  def configure_assets
    @platform_instance.configure_assets
  end

  def copy_configurations
    @platform_instance.copy_configurations
  end

  def configure_it
    configure_firebase
    configure_fastlane
    configure_assets
    copy_configurations
    clean_cached_files
  end

  def clean_cached_files
    CarrierWave.clean_cached_files!
  end
end
