module AppsHelper

  include UrlHelper

  def modify_android_configuration_files folder, app
      build_gradle = Dir.glob("#{folder}/**/build.gradle")
      manifest = Dir.glob("#{folder}/**/app/**/AndroidManifest.xml").first

      document = Nokogiri::XML(File.open(manifest))
      application = document.at('application')

      application.children.each { |item|
        if (item.name == 'meta-data')
          next unless item.attributes['name'].value == 'kolibri_navigation_url'
          @attr = item
        end
      }

      if @attr.nil?
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.send(:"meta-data", 'android:name' => 'kolibri_navigation_url', 'android:value' => runtime_app_url(app))
        end
        @attr = builder.doc.root
        application << @attr
      else
        @attr.attributes['value'].value = runtime_app_url app
      end

      puts @attr.to_xml

      File.write(manifest, document.to_xml)
  end
end
