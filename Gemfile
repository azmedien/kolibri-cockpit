source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.5.3"

gem 'rails', '~> 5.2.0'
gem 'pg'
gem 'puma', '~> 3.11'
gem 'sidekiq'
gem 'bootsnap', '>= 1.1.0', require: false

# Assets pipeline and frontend
gem 'sassc-rails', '~> 2'
gem 'coffee-rails', '~> 4.2'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

gem 'rpush', github: 'L3K0V/rpush', branch: 'fcm'
gem 'net-http-persistent', '< 3'

gem 'version'

gem 'devise'
gem 'devise_invitable'
gem 'authority'
gem 'rolify'
gem 'paper_trail'
gem 'hashdiff'
gem 'kaminari'

gem 'git', '~> 1'

gem 'carrierwave', '~> 1.2'
gem 'copy_carrierwave_file'

gem 'mini_magick'

gem 'friendly_id', '~> 5.2'

gem 'bootstrap', '~> 4.1'
gem "font-awesome-rails"

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.4'
  gem 'rails-assets-jsoneditor', '~> 5'
end

gem 'jenkins_api_client', '~> 1.5'
gem 'xcodeproj'
gem 'plist'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
  gem 'redis', '~> 4.0'
  gem 'fog-aws'
  gem 'newrelic_rpm'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
