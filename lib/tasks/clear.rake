namespace :clear do
  desc "Remove all notifications for all the apps"
  task notifications: :environment do
    App.all.each do |app|
      notification = Rpush::Gcm::App.find_by_name(app.internal_id)
      Rpush::Gcm::Notification.where(app_id: notification.id).destroy_all if notification
    end
  end

  desc "Remove all the builds for all the apps"
  task builds: :environment do
    App.all.each do |app|
      app.builds.destroy_all
    end
  end
end
