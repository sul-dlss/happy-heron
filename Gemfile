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
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'super_diff', require: false
  gem 'webmock' # test calls to external QA lookup service for autocomplete
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'multi_json', require: false # needed to update RBIs after adding reform-rails
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'state_machines-graphviz'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '~> 3.34'
  gem 'capybara-screenshot'
  gem 'cuprite'
end

group :deployment do
  gem 'capistrano-maintenance', '~> 1.2', require: false
  gem 'capistrano-rails', require: false
  gem 'dlss-capistrano-docker', github: 'sul-dlss/dlss-capistrano-docker', branch: 't2-rollback', require: false
end

gem 'action_policy', '~> 0.5.3'
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
gem 'faker'
gem 'faraday', '~> 2.0'
gem 'honeybadger', '~> 4.0'
gem 'jbuilder'
gem 'jsbundling-rails', '~> 0.1.9'
gem 'lograge', '~> 0.11.2'
gem 'okcomputer'
gem 'pg'
gem 'preservation-client', '~> 5.0'
gem 'propshaft'
gem 'pry'
gem 'puma', '~> 5.6', '>= 5.6.4'
gem 'redis', '~> 4.0'
# TODO: Deal with this
# pinned because 2.6.0 broke the build: [Reform] Your :populator did not return a Reform::Form instance for `authors`.
gem 'reform', '~> 2.5.0'
gem 'reform-rails', '~> 0.2.0'
gem 'sdr-client', '~> 0.94'
gem 'sidekiq', '~> 6.1'
gem 'sneakers', '~> 2.11' # rabbitMQ background processing
gem 'state_machines-activerecord'
gem 'turbo-rails', '~> 1.0'
gem 'view_component', '~> 2.56.2' # https://github.com/github/view_component/issues/1390
gem 'whenever'
gem 'zipline', '~> 1.4'
