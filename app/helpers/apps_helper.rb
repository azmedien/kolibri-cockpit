module AppsHelper

  include UrlHelper


  def setup_android_title folder, app
    string_xml = Dir.glob("#{folder}/**/app/**/res/values/strings.xml").first
    update_android_xml string_xml, 'app_name', app.internal_name if string_xml
  end

  def modify_android_configuration_files folder, app
      build_gradle = Dir.glob("#{folder}/**/app/**/build.gradle").first
      manifest = Dir.glob("#{folder}/**/app/**/AndroidManifest.xml").first

      netmetrix_url = app.android_config['netmetrix_url']
      netmetrix_ua = app.android_config['netmetrix_ua']

      update_android_meta(manifest, 'kolibri_navigation_url', runtime_app_url(app))
      update_android_meta(manifest, 'kolibri_netmetrix_url', netmetrix_url) unless netmetrix_url.nil? || netmetrix_url.empty?
      update_android_meta(manifest, 'kolibri_netmetrix_ua', netmetrix_ua) unless netmetrix_ua.nil? || netmetrix_ua.empty?

      # FIXME: Remove me
      update_android_meta(manifest, 'io.fabric.ApiKey', '5b0e4ca8fe72e1ad97ccbd82e18f18ba4cacd219')

      update_android_gradle build_gradle, app
      update_android_fastlane folder, app
  end

  def modify_ios_configuration_files folder, app

    netmetrix_url = app.ios_config['netmetrix_url']
    netmetrix_ua = app.ios_config['netmetrix_ua']
    bundle_id = app.ios_config['bundle_id']

    update_ios_plist(folder, 'kolibri_navigation_url', runtime_app_url(app))
    update_ios_plist(folder, 'kolibri_netmetrix_url', netmetrix_url) unless netmetrix_url.nil? || netmetrix_url.empty?
    update_ios_plist(folder, 'kolibri_netmetrix_ua', netmetrix_ua) unless netmetrix_ua.nil? || netmetrix_ua.empty?

    update_ios_bundle_id folder, bundle_id
  end

  private
  def update_ios_plist folder, meta, value
    plist_path = Dir.glob("#{folder}/**/**/Info.plist").first
    plist = Plist.parse_xml(plist_path)

    if plist['KolibriParameters'].nil?
      params = {}
      params[meta] = value
      plist['KolibriParameters'] = params
    else
      plist['KolibriParameters'][meta] = value
    end

    plist_string = Plist::Emit.dump(plist)
    File.write(plist_path, plist_string)
  end

  def update_ios_bundle_id folder, value
    require 'xcodeproj'
    require 'plist'
    require 'pathname'

    info_plist_key = 'INFOPLIST_FILE'
    identifier_key = 'PRODUCT_BUNDLE_IDENTIFIER'

    project_path = Dir.glob("#{folder}/**.xcodeproj").first
    plist_path = Dir.glob("#{folder}/**/**/Info.plist").first
    plist = Plist.parse_xml(plist_path)

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
        c.build_settings[identifier_key] = value
      end

      # Write changes to the file
      project.save
    else
      # Update plist value
      plist['CFBundleIdentifier'] = value

      # Write changes to file
      plist_string = Plist::Emit.dump(plist)
      File.write(info_plist_path, plist_string)
    end
  end


  def update_android_fastlane folder, app

    if Dir.glob("#{folder}/**/app/fastlane/Fastlane").any?
      logger.info 'Fastlane already configured. Skipped'
      return
    end

    require 'fileutils'
    require 'tempfile'

    app_folder = Dir.glob("#{folder}/**/app/").first
    dir = File.join(File.dirname(app_folder), "fastlane")

    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end

    appfile = Dir.glob("#{dir}/Appfile").first

    Tempfile.open(".#{File.basename(appfile)}", File.dirname(appfile)) do |tempfile|
      File.open(appfile).each do |line|
        tempfile.puts line.gsub(/(package_name) (\".*?\")/, '\1 "' + app.android_config['bundle_id'] + '"')
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
      locals: { app: app }
    })

    # FIXME: Remove me
    api = 'apiSecret=8f94e66fae0366a48a613623166a2586ae77e7fab1b68d021471e0036ba46ad8'

    File.write(File.join(app_folder, "fabric.properties"), api.to_s)
    File.write(File.join(dir, "Fastfile"), fastlane.to_s)
  end

  def update_android_gradle gradle, app
    require 'tempfile'

    applicationId = app.android_config['bundle_id']
    code = app.android_config['version_code']
    name = app.android_config['version_name']

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
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send(:"meta-data", 'android:name' => meta, 'android:value' => value)
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
      if (item.attributes['name'].value == meta)
          element = item if item.attributes['name'].value == meta
      end
    }

    element.children.first.content = value if element && element.children.any?

    File.write(xml, document.to_xml(indent: 4))
  end
end
