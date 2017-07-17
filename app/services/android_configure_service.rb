require_dependency 'file_helper'

class AndroidConfigureService

  include FileHelper
  include UrlHelper

  def initialize(folder, app)
    @app = app
    @app_folder = Dir.glob("#{folder}/**/app").first
    @log = Rails.logger
  end

  def configure_firebase
    @log.tagged("Firebase") do

      firebase = @app.android_firebase

      unless firebase.file.nil?
        @log.info "Processing #{@app.android_firebase_identifier}"
        @log.debug "Caching..."
        firebase.cache_stored_file!
        firebase.retrieve_from_cache!(firebase.cache_name)
        @log.debug "Retrieved from cache!"

        FileUtils.cp firebase.path, "#{@app_folder}/google-services.json"
        @log.debug "Copy #{firebase.path} -> #{@app_folder}/google-services.json"
        @log.info "Firebase JSON file copied successfully"
      else
        @log.warn "Firebase JSON is not set. Skipping..."
      end
    end
  end

  def configure_fastlane
    @log.tagged("Fastlane") do
      if Dir.glob("#{@app_folder}/fastlane/Fastfile").any?
        logger.info 'Fastlane already configured. Skipping...'
        return
      end

      dir = File.join(File.dirname(@app_folder), "fastlane")

      unless File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end

      appfile = Dir.glob("#{dir}/Appfile").first

      Tempfile.open(".#{File.basename(appfile)}", File.dirname(appfile)) do |tempfile|
        File.open(appfile).each do |line|
          tempfile.puts line.gsub(/(package_name) (\".*?\")/, '\1 "' + @app.android_config['bundle_id'] + '"')
        end
        tempfile.fdatasync
        tempfile.close
        stat = File.stat(appfile)
        FileUtils.chown stat.uid, stat.gid, tempfile.path
        FileUtils.chmod stat.mode, tempfile.path
        FileUtils.mv tempfile.path, appfile
      end

      fastlane = ApplicationController.renderer.render({
        partial: 'layouts/fastlane',
        locals: { app: @app }
      })

      File.write(File.join(dir, "Fastfile"), fastlane.to_s)
    end
  end

  def configure_assets
    @log.tagged("Assets") do
      copy_assets
      copy_icon
      copy_splash
    end
  end

  def copy_configurations
    string_xml = Dir.glob("#{@app_folder}/**/res/values/strings.xml").first
    build_gradle = Dir.glob("#{@app_folder}/**/build.gradle").first
    manifest = Dir.glob("#{@app_folder}/**/AndroidManifest.xml").first

    @log.tagged("Configurations") do
      @log.debug "Configure application name"
      update_android_xml(string_xml, 'app_name', @app.internal_name) if string_xml

      @log.debug "Configure runtime configuration meta"
      update_android_meta(manifest, 'kolibri_navigation_url', runtime_app_url(@app))
      update_android_meta(manifest, 'kolibri_runtime_configuration', runtime_app_url(@app))

      @log.debug "Configure fabric api key meta"
      update_android_meta(manifest, 'io.fabric.ApiKey', '5b0e4ca8fe72e1ad97ccbd82e18f18ba4cacd219')

      @log.debug "Configure bundle name and version into gradle script"
      update_android_gradle build_gradle

      @log.debug "Configure fabric api secret"
      api = 'apiSecret=8f94e66fae0366a48a613623166a2586ae77e7fab1b68d021471e0036ba46ad8'
      File.write(File.join(@app_folder, "fabric.properties"), api.to_s)

      @log.info "Setup and copy of all required configurations are done."
    end
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
        asset.file.versions.each do |version|

          next if version.first.to_s == 'x2' || version.first.to_s == 'x3'

          @log.debug "Processing #{version.first} of #{asset.file_identifier}"

          dest = Dir.glob("#{@app_folder}/**/res").first
          FileUtils.mkdir_p(File.dirname("#{dest}/drawable-#{version.first}/#{asset.file_identifier}"))
          FileUtils.cp version.last.file.path, "#{dest}/drawable-#{version.first}/#{asset.file_identifier}"

          @log.debug "Copy #{version.last.file.path} -> #{dest}/drawable-#{version.first}/#{asset.file_identifier}"
          @log.debug "Successfully processed #{version.first} of #{asset.file_identifier}"
        end
      end

      @log.info "Successfully processed #{asset.file_identifier}"

    end
  end

  def copy_icon

    icon = @app.android_icon

    unless icon.file.nil?
      @log.info "Processing #{@app.android_icon_identifier}"
      @log.debug "Caching..."
      icon.cache_stored_file!
      icon.retrieve_from_cache!(icon.cache_name)
      @log.debug "Retrieved from cache!"

      icon.versions.each do |version|

        @log.debug "Processing #{version.first} of #{@app.android_icon_identifier}"

        dest = Dir.glob("#{@app_folder}/**/res").first
        FileUtils.mkdir_p(File.dirname("#{dest}/mipmap-#{version.first}/ic_launcher.png"))
        FileUtils.cp version.last.file.path, "#{dest}/mipmap-#{version.first}/ic_launcher.png"

        @log.debug "Copy #{version.last.file.path} -> #{dest}/mipmap-#{version.first}/ic_launcher.png"
        @log.debug "Successfully processed #{version.first} of #{@app.android_icon_identifier}"
      end

      @log.info "Successfully processed #{@app.android_icon_identifier}"
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

      dest = Dir.glob("#{@app_folder}/**/res").first
      FileUtils.mkdir_p(File.dirname("#{dest}/drawable/#{@app.splash_identifier}"))
      FileUtils.cp splash.path, "#{dest}/drawable/#{@app.splash_identifier}"

      @log.debug "Copy #{splash.path} -> #{dest}/drawable/#{@app.splash_identifier}"
      @log.info "Successfully processed #{@app.splash_identifier}"
    else
      @log.warn "Application splash is not set. Skipping.."
    end
  end

  def update_android_meta xml, meta, value
    attribute = nil
    document = Nokogiri::XML(File.open(xml), &:noblanks)
    application = document.at('application')

    application.children.each { |item|
      if (item.name == 'meta-data')
          attribute = item if item.attributes['name'].value == meta
      end
    }

    if attribute.nil?
      builder = Nokogiri::XML::Builder.new do |doc|
        doc.send(:"meta-data", 'android:name' => meta, 'android:value' => value)
      end

      attribute = builder.doc.root
      application << attribute
    else
      attribute.attributes['value'].value = value
    end

    File.write(xml, document.to_xml(indent: 4))
  end

  def update_android_xml xml, meta, value
    element = nil
    document = Nokogiri::XML(File.open(xml), &:noblanks)
    resources = document.at('resources')

    resources.children.each { |item|
      if (item.element? && item.attributes['name'].value == meta)
          element = item if item.attributes['name'].value == meta
      end
    }

    element.children.first.content = value if element && element.children.any?

    File.write(xml, document.to_xml(indent: 4, encoding: 'UTF-8'))
  end

  def update_android_gradle gradle
    applicationId = @app.android_config['bundle_id']
    code = @app.android_config['version_code']
    name = @app.android_config['version_name']

    Tempfile.open(".#{File.basename(gradle)}", File.dirname(gradle)) do |tempfile|
      File.open(gradle).each do |line|
        new_line = line.gsub!(/(applicationId) (\".*?\")/, '\1 "' + applicationId + '"') ||
          line.gsub!(/(versionCode) (\d*)/, '\1 ' + code + '') ||
          line.gsub!(/(versionName) (\".*?\")/, '\1 "' + name + '"')

        tempfile.puts new_line || line
      end

      tempfile.fdatasync
      tempfile.close
      stat = File.stat(gradle)
      FileUtils.chown stat.uid, stat.gid, tempfile.path
      FileUtils.chmod stat.mode, tempfile.path
      FileUtils.mv tempfile.path, gradle
    end
  end
end
