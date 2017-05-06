module AppsHelper

  include UrlHelper

  def modify_android_configuration_files folder, app
      build_gradle = Dir.glob("#{folder}/**/build.gradle")
      manifest = Dir.glob("#{folder}/**/app/**/AndroidManifest.xml").first

      update_or_append_android_meta manifest, 'kolibri_navigation_url', runtime_app_url(app)
      update_or_append_android_meta(manifest, 'kolibri_netmetrix_url', app.android_config['netmetrix_url']) unless app.android_config['netmetrix_url'].nil?
  end

  private
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
