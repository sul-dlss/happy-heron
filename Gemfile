# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'rails', '~> 7.2'

group :development, :test do
  gem 'axe-core-rspec'
  gem 'cypress-on-rails', '~> 1.0'
  gem 'cypress-rails'
  gem 'debug'
  gem 'erb_lint', require: false
  # NOTE: factory_bot_rails >= 6.3.0 requires env/test.rb to have
  # config.factory_bot.reject_primary_key_attributes = false
  gem 'factory_bot_rails'
  gem 'rspec'
  gem 'rspec_junit_formatter' # used by CircleCI
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'simplecov', require: false
  gem 'super_diff', require: false
  gem 'webmock' # test calls to external QA lookup service for autocomplete
end

group :development do
  gem 'faker'
  gem 'listen', '~> 3.2'
  gem 'multi_json', require: false
  gem 'puma'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'state_machines-graphviz'
  gem 'tty-progressbar'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '~> 3.34'
  gem 'capybara-screenshot'
  gem 'cuprite' # Pure Ruby headless Chrome web driver used for Capybara feature tests
  gem 'selenium-webdriver' # Used as Capybara driver by axe-core-rspec gem for accessibility tests
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
gem 'config'
gem 'cssbundling-rails'
gem 'csv'
gem 'devise', '~> 4.7'
gem 'devise-remote-user', '~> 1.0'
gem 'dor-services-client', '~> 14.0'
gem 'druid-tools'
gem 'dry-types'
gem 'edtf'
gem 'faraday', '~> 2.0'
gem 'globus_client', '~> 0.11'
gem 'honeybadger'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'lograge', '~> 0.11.2'
gem 'mais_orcid_client'
gem 'mutex_m' # This can be removed when H2 is upgraded to Rails 7.1
gem 'okcomputer'
gem 'pg'
gem 'preservation-client', '~> 6.0'
gem 'propshaft'
gem 'pry'
gem 'redis', '~> 4.0'
# TODO: Deal with this
# pinned because 2.6.0 broke the build: [Reform] Your :populator did not return a Reform::Form instance for `authors`.
gem 'dor-workflow-client'
gem 'reform', '~> 2.5.0'
gem 'reform-rails'
gem 'rubyzip', '~> 2.3'
gem 'sdr-client', '~> 2.14'
gem 'sidekiq', '~> 7.0'
gem 'sneakers', '~> 2.11' # rabbitMQ background processing
gem 'state_machines-activerecord'
gem 'strip_attributes'
gem 'turbo-rails', '~> 1.0'
gem 'view_component'
gem 'whenever', require: false # Work around https://github.com/javan/whenever/issues/831
gem 'zipline', '~> 1.4'
