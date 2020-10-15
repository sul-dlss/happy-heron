# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'bootsnap', '>= 1.4.2', require: false
gem 'config', '~> 2.2'
gem 'devise', '~> 4.7'
gem 'devise-remote-user', '~> 1.0'
gem 'dor-services-client'
gem 'pg'
gem 'rails', '~> 6.0.3', '>= 6.0.3.2'
gem 'redis', '~> 4.0'
gem 'sidekiq', '~> 6.1'
gem 'sorbet-rails' # used both statically and at runtime
gem 'sorbet-runtime'
gem 'state_machines-activerecord'
gem 'turbolinks', '~> 5'
gem 'view_component', '~> 2.18'
gem 'webpacker', '~> 5.0'

group :development, :test do
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'rspec'
  gem 'rspec_junit_formatter' # used by CircleCI
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-sorbet', require: false
  # CodeClimate is not compatible with 0.18+. See https://github.com/codeclimate/test-reporter/issues/413
  gem 'simplecov', '~> 0.17.1', require: false
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'puma', '~> 4.1'
  gem 'sorbet'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'apparition'
  gem 'capybara', '>= 2.15'
end

group :deployment do
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'dlss-capistrano', '~> 3.6', require: false
end
