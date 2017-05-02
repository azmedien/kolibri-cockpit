class ConfigureAppJob < ApplicationJob

  include GitHelper
  include ApplicationHelper
  include AppsHelper
  include AssetsHelper
  include UrlHelper

  queue_as :default

  def perform(app)
    repo = app.android_config['repository_url']
    bundle = app.android_config['bundle_id']

    open_repo repo
    manipulate_repo repo do |git|

      modify_android_configuration_files '.', app

      File.open("#{app.internal_id}.txt", "w") do |f|
        f.write(runtime_app_url app)
      end
    end

    send_cable
  end
end
