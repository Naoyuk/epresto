# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'cssbundling-rails'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'pg', '~> 1.1'
gem 'propshaft'
gem 'puma', '4.3.12'
gem 'rails', '~> 7.0.4'
gem 'redis', '~> 4.0'
gem 'stimulus-rails'
gem 'turbo-rails'
# gem "kredis"
# gem "bcrypt", "~> 3.1.7"
gem 'bootsnap', require: false
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
# gem "image_processing", "~> 1.2"
gem 'aws-sigv4'
gem 'cancancan'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'csv'
gem 'devise'
gem 'dotenv-rails', '2.7.6'
gem 'kaminari'
gem 'ransack'
gem 'rolify'
gem 'roo'
gem 'rubyzip'
gem 'business_time'

group :development, :test do
  gem 'capistrano', '~> 3.17.1'
  gem 'capistrano3-puma'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-rbenv'
  gem 'capistrano-yarn'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :development do
  gem 'web-console'
  # gem "rack-mini-profiler"
  # gem "spring"
end

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
end
