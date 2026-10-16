source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'shopify_app', '~>16.0.0'
gem 'jquery-ui-rails', '~>6.0.1'
gem 'jquery-rails', '~> 4.3.1'
gem 'delayed_job_active_record', '~> 4.1.2'
gem 'paperclip', '~> 6.0.0'
gem 'email_verifier', '~> 0.1.0'
gem 'ransack'
gem 'will_paginate', '~> 3.1.0'
gem 'select2-rails', '~> 4.0.3'
gem 'font-awesome-rails'
gem "bugsnag", "~> 6.7"

gem 'rails', '~> 5.2'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer'
gem 'daemons'

gem 'validates_zipcode', '~> 0.5.0'

group :development, :test do
  gem 'mysql2', '>= 0.3.18', '< 0.5'
  gem 'byebug', '~>10.0.1', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver', '~> 3.11.0'
end

group :staging, :production do
  gem 'pg'
  gem 'activerecord-postgis-adapter'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  gem 'rb-readline'
end
