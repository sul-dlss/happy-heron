# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 7.0.1'

group :development, :test do
  gem 'byebug'
  gem 'cypress-on-rails', '~> 1.0'
  gem 'cypress-rails'
  gem 'factory_bot_rails'
  gem 'rspec'
  gem 'rspec_junit_formatter' # used by CircleCI
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'super_diff', require: false
  gem 'webmock' # test calls to external QA lookup service for autocomplete
end

group :development do
  gem 'faker'
  gem 'listen', '~> 3.2'
  gem 'multi_json', require: false
  gem 'puma', '~> 5.6', '>= 5.6.4'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'state_machines-graphviz'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '~> 3.34'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver' # for js testing
  gem 'webdrivers' # installs the chrome for selenium tests
end

group :deployment do
  gem 'capistrano-maintenance', '~> 1.2', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'dlss-capistrano', require: false
end

gem 'action_policy', '~> 0.6.5'
gem 'addressable', '~> 2.8.0'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'bunny', '~> 2.17' # RabbitMQ library
gem 'config', '~> 2.2'
gem 'cssbundling-rails', '~> 0.2.4'
gem 'devise', '~> 4.7'
gem 'devise-remote-user', '~> 1.0'
gem 'druid-tools'
gem 'dry-types'
gem 'edtf'
gem 'faraday', '~> 2.0'
gem 'globus_client', '~> 0.8'
gem 'honeybadger', '~> 4.0'
gem 'jbuilder'
gem 'jsbundling-rails', '~> 0.1.9'
gem 'lograge', '~> 0.11.2'
gem 'okcomputer'
gem 'pg'
gem 'preservation-client', '~> 6.0'
gem 'propshaft'
gem 'pry'
gem 'redis', '~> 4.0'
# TODO: Deal with this
# pinned because 2.6.0 broke the build: [Reform] Your :populator did not return a Reform::Form instance for `authors`.
gem 'reform', '~> 2.5.0'
gem 'reform-rails'
gem 'rubyzip', '~> 2.3'
gem 'sdr-client', '~> 2.0'
gem 'sidekiq', '~> 7.0'
gem 'sneakers', '~> 2.11' # rabbitMQ background processing
gem 'state_machines-activerecord'
gem 'turbo-rails', '~> 1.0'
gem 'view_component', '~> 2.56.2' # https://github.com/github/view_component/issues/1390
gem 'whenever', require: false # Work around https://github.com/javan/whenever/issues/831
gem 'zipline', '~> 1.4'
