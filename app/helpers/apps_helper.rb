module AppsHelper

  include UrlHelper

  def modify_android_configuration_files folder, app
      build_gradle = Dir.glob("#{folder}/**/app/**/build.gradle").first
      manifest = Dir.glob("#{folder}/**/app/**/AndroidManifest.xml").first

      update_or_append_android_meta manifest, 'kolibri_navigation_url', runtime_app_url(app)
      update_or_append_android_meta(manifest, 'kolibri_netmetrix_url', app.android_config['netmetrix_url']) unless app.android_config['netmetrix_url'].nil?

      update_or_append_android_gradle build_gradle, 'applicationId', app.android_config['bundle_id']

      update_or_append_android_fastlane folder, app
  end

  private
  def update_or_append_android_fastlane folder, app

    if Dir.glob("#{folder}/**/app/fastlane/Fastlane").any?
      logger.info 'Fastlane already configured. Skipped'
      return
    end

    require 'fileutils'

    app_folder = Dir.glob("#{folder}/**/app/").first
    dir = File.join(File.dirname(app_folder), "fastlane")

    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
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

  def update_or_append_android_gradle gradle, meta, value
    require 'tempfile'

    Tempfile.open(".#{File.basename(gradle)}", File.dirname(gradle)) do |tempfile|
      File.open(gradle).each do |line|
        tempfile.puts line.gsub(/(applicationId) (\".*?\")/, '\1 "' + value + '"')

        # s.gsub(/(applicationId).*?/, '\1replacement text')
      end
      tempfile.fdatasync
      tempfile.close
      stat = File.stat(gradle)
      FileUtils.chown stat.uid, stat.gid, tempfile.path
      FileUtils.chmod stat.mode, tempfile.path
      FileUtils.mv tempfile.path, gradle
    end
  end

  def update_or_append_android_meta xml, meta, value
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
end
