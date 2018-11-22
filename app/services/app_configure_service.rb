class AppConfigureService
  attr_reader :platform_instance, :folder, :build

  def initialize(platform, folder, build)
    @platform_instance = "#{platform.capitalize}ConfigureService".constantize.new(folder, build)
  end

  def configure_firebase
    @platform_instance.configure_firebase
  end

  def configure_fastlane channels
    @platform_instance.configure_fastlane channels
  end

  def configure_assets
    @platform_instance.configure_assets
  end

  def copy_configurations
    @platform_instance.copy_configurations
  end

  def configure_it channels
    configure_firebase
    configure_fastlane channels
    configure_assets
    copy_configurations
    clean_cached_files
  end

  def clean_cached_files
    CarrierWave.clean_cached_files!
  end
end
