require_dependency 'file_helper'

class IosConfigureService

  include FileHelper
  include UrlHelper

  def initialize(folder, build)
    @build = build
    @app = build.app
    @app_folder = folder
    @log = Rails.logger
  end

  def configure_firebase
    @log.tagged("Firebase") do

      send_build_update_cable(@build, 'firebase', 0, "Configure Firebase to app...")
      firebase = @app.ios_firebase

      unless firebase.file.nil?
        @log.info "Processing #{@app.ios_firebase_identifier}"
        @log.debug "Caching..."
        firebase.cache_stored_file!
        firebase.retrieve_from_cache!(firebase.cache_name)
        @log.debug "Retrieved from cache!"

        FileUtils.cp firebase.path, "#{@app_folder}/GoogleService-Info.plist"
        @log.debug "Copy #{firebase.path} -> #{@app_folder}/GoogleService-Info.plist"
        @log.info "Firebase plist file copied successfully"
      else
        @log.warn "Firebase plist is not set. Skipping..."
      end

      send_build_update_cable(@build, 'firebase', 1, "Firebase configured")
    end
  end

  def configure_fastlane channels
    @log.tagged("Fastlane") do
      if Dir.glob("#{@app_folder}/fastlane/Fastfile").any?
        @log.info 'Fastlane already configured. Skipped'
        return
      end

      send_build_update_cable(@build, 'fastlane', 0, "Configure Fastlane to app for channels #{channels}")
      dir = File.join(File.dirname(@app_folder), "fastlane")

      unless File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end

      fastlane = ApplicationController.renderer.render({
        partial: 'layouts/fastlane',
        locals: { app: @app, channels: channels }
      })

      File.write(File.join(dir, "Fastfile"), fastlane.to_s)
      send_build_update_cable(@build, 'firebase', 1, "Fastlane configured")
    end
  end

  def configure_assets
    @log.tagged("Assets") do
      send_build_update_cable(@build, 'assets', 0, "Copying assets to app..")
      copy_assets
      copy_icon
      copy_splash
      send_build_update_cable(@build, 'assets', 1, "Assets copied.")
    end
  end

  def copy_configurations
    send_build_update_cable(@build, 'configurations', 0, "Copy platform specific configurations to app...")
    require 'xcodeproj'
    require 'pathname'

    info_plist_key = 'INFOPLIST_FILE'
    identifier_key = 'PRODUCT_BUNDLE_IDENTIFIER'

    project_path = Dir.glob("#{@app_folder}/**.xcodeproj").first
    plist_path = Dir.glob("#{@app_folder}/Kolibri/Resources/App/pLists/Info.plist").first

    modify_plist(plist_path) do |plist|
      plist['CFBundleDisplayName'] = @app.internal_name
      plist['CFBundleShortVersionString'] = @app.ios_config['version_name'] || "1.0.0"
      plist['CFBundleVersion'] = @app.ios_config['version_code'] || "1"

      if plist['KolibriParameters'].nil?
        params = {}
        params['kolibri_navigation_url'] = runtime_app_url(@app)
        params['kolibri_runtime_configuration'] = runtime_app_url(@app)
        plist['KolibriParameters'] = params
      else
        plist['KolibriParameters']['kolibri_navigation_url'] = runtime_app_url(@app)
        plist['KolibriParameters']['kolibri_runtime_configuration'] = runtime_app_url(@app)
      end

      if plist['CFBundleIdentifier'] == "$(#{identifier_key})"

        # Load .xcodeproj
        project = Xcodeproj::Project.open(project_path)

        current = Pathname.new '.'
        plist_pathname = Pathname.new plist_path

        # Fetch the build configuration objects
        configs = project.objects.select { |obj| obj.isa == 'XCBuildConfiguration' && !obj.build_settings[identifier_key].nil? }
        configs = configs.select { |obj| obj.build_settings[info_plist_key] == plist_pathname.relative_path_from(current).to_s }
        # For each of the build configurations, set app identifier
        configs.each do |c|
          c.build_settings[identifier_key] = @app.ios_config['bundle_id']
        end

        # Write changes to the file
        project.save
      else
        # Update plist value
        plist['CFBundleIdentifier'] = @app.ios_config['bundle_id']
      end
    end

    resources = Dir.glob("#{@app_folder}/Kolibri/Resources").first

    FileUtils.mkdir_p(File.dirname("#{resources}/Defaults/runtime.json"))
    File.write(File.join("#{resources}/Defaults", "runtime.json"), JSON.parse(@app.runtime))
    send_build_update_cable(@build, 'configurations', 1, "Setup and copy of all required configurations are done.")
  end

  private
  def copy_assets
    assets = @app.assets

    assets.each do |asset|
      @log.info "Processing #{asset.file_identifier}"
      @log.debug "Caching..."
      asset.file.cache_stored_file!
      asset.file.retrieve_from_cache!(asset.file.cache_name)
      @log.debug "Retrieved from cache!"

      # Copy drawable resources
      if asset.content_type.starts_with?('image/')
          FileUtils.mkdir_p(File.dirname("#{@app_folder}/blade/images/#{asset.file_identifier}"))
          FileUtils.cp asset.file.path, "#{@app_folder}/blade/images/#{asset.file_identifier}"
      end

      @log.info "Successfully processed #{asset.file_identifier}"
    end

    bladefile = ApplicationController.renderer.render({
      partial: 'layouts/bladefile',
      locals: { app: @app, assets: assets.select { |item| item.content_type.starts_with?('image/')} }
    })

    File.write(File.join(@app_folder, "Bladefile"), bladefile.to_s)

    @log.info "Bladefile done"
  end

  def copy_icon

    icon = @app.ios_icon

    unless icon.file.nil?
      @log.info "Processing #{@app.ios_icon_identifier}"
      @log.debug "Caching..."
      icon.cache_stored_file!
      icon.retrieve_from_cache!(icon.cache_name)
      @log.debug "Retrieved from cache!"

      FileUtils.mkdir_p(File.dirname("#{@app_folder}/blade/images/#{@app.ios_icon_identifier}"))
      FileUtils.cp icon.path, "#{@app_folder}/blade/images/#{@app.ios_icon_identifier}"

      @log.info "Successfully processed #{@app.ios_icon_identifier}"
    else
      @log.warn "Application icon is not set. Skipping.."
    end
  end

  def copy_splash

    splash = @app.splash

    unless splash.file.nil?
      @log.info "Processing #{@app.splash_identifier}"
      @log.debug "Caching..."
      splash.cache_stored_file!
      splash.retrieve_from_cache!(splash.cache_name)
      @log.debug "Retrieved from cache!"

      FileUtils.mkdir_p(File.dirname("#{@app_folder}/blade/images/#{@app.splash_identifier}"))
      FileUtils.cp splash.path, "#{@app_folder}/blade/images/#{@app.splash_identifier}"

      @log.debug "Copy #{splash.path} -> #{@app_folder}/blade/images/#{@app.splash_identifier}"
      @log.info "Successfully processed #{@app.splash_identifier}"
    else
      @log.warn "Application splash is not set. Skipping.."
    end
  end
end
