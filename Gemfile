# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

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
  gem 'super_diff', require: false
end

group :development do
  gem 'faker'
  gem 'listen', '~> 3.2'
  gem 'multi_json', require: false # needed to update RBIs after adding reform-rails
  gem 'puma', '~> 4.1'
  gem 'sorbet', '0.5.5981' # pin until https://github.com/sorbet/sorbet/issues/3561 is resolved
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'state_machines-graphviz'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'apparition'
  gem 'capybara', '~> 3.34'
  gem 'capybara-screenshot'
  gem 'rspec-sorbet'
end

group :deployment do
  gem 'capistrano-maintenance', '~> 1.2', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'dlss-capistrano', '~> 3.6', require: false
end

gem 'action_policy', '~> 0.5.3'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'config', '~> 2.2'
gem 'devise', '~> 4.7'
gem 'devise-remote-user', '~> 1.0'
gem 'dor-services-client'
gem 'druid-tools'
gem 'dry-types'
gem 'edtf'
gem 'honeybadger', '~> 4.0'
gem 'jbuilder'
gem 'okcomputer'
gem 'pg'
gem 'rails', '~> 6.0.3', '>= 6.0.3.2'
gem 'redis', '~> 4.0'
gem 'reform-rails', '~> 0.2.0'
gem 'sdr-client', '~> 0.39'
gem 'sidekiq', '~> 6.1'
# pinned because 0.7.2 broke the build with 181 new errors related (apparently?) to the parlour 5.0.0 bump
gem 'sorbet-rails', '0.7.1'
gem 'sorbet-runtime'
gem 'state_machines-activerecord'
gem 'turbolinks', '~> 5'
gem 'view_component', '~> 2.18'
gem 'webpacker', '~> 5.0'
gem 'whenever'
