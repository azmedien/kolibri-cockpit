namespace :roles do
  desc "Give all app owners admin roles to their apps"
  task :admins => :environment do
    App.all.each do |app|
      app.user.add_role(:admin, app)
    end
  end

  desc "Give push notifications role to an user for given app"
  task :push, [:app, :user] => :environment do |task, args|
    app = App.find_by_internal_id(args[:app])
    user = User.find_by_email(args[:user])

    if user && app
      user.add_role(:push, app)
      puts "#{user.email} now has push permissions to #{app.internal_name}"
    else
      puts "Invalid task arguments"
    end
  end
end
