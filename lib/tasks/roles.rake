namespace :roles do
  desc "Give all app owners admin roles to their apps"
  task :admins => :environment do
    App.all.each do |app|
      app.user.add_role(:admin, app)
    end
  end
end
