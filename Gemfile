# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails", "~> 7.0.1"

group :development, :test do
  gem "axe-core-rspec"
  gem "byebug"
  gem "cypress-on-rails", "~> 1.0"
  gem "cypress-rails"
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "rspec"
  gem "rspec_junit_formatter" # used by CircleCI
  gem "rspec-rails"
  # NOTE: the `standard` way does not support using the rubocop CLI with
  # extensions like standard-rails, so until that changes or we decide to switch
  # to the standardrb CLI (which would need CI and editor support), we have to
  # carry both this dependency and standard-rails.
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "simplecov", require: false
  gem "standard", "< 1.30", require: false # TODO: 1.30.x breaks build as of 2023-07-10, unpin once a later release fixes this, or if suggested workaround is acceptable and fixes the issue, see https://github.com/standardrb/standard/issues/569
  gem "standard-rails", require: false
  gem "super_diff", require: false
  gem "webmock" # test calls to external QA lookup service for autocomplete
end

group :development do
  gem "faker"
  gem "listen", "~> 3.2"
  gem "multi_json", require: false
  gem "puma", "~> 5.6", ">= 5.6.4"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "state_machines-graphviz"
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", "~> 3.34"
  gem "capybara-screenshot"
  gem "cuprite" # Pure Ruby headless Chrome web driver used for Capybara feature tests
  gem "selenium-webdriver" # Used as Capybara driver by axe-core-rspec gem for accessibility tests
end

group :deployment do
  gem "capistrano-maintenance", "~> 1.2", require: false
  gem "capistrano-passenger", require: false
  gem "capistrano-rails", require: false
  gem "dlss-capistrano", require: false
end

gem "action_policy", "~> 0.6.5"
gem "addressable", "~> 2.8.0"
gem "bootsnap", ">= 1.4.2", require: false
gem "bunny", "~> 2.17" # RabbitMQ library
gem "config", "~> 2.2"
gem "cssbundling-rails", "~> 0.2.4"
gem "devise", "~> 4.7"
gem "devise-remote-user", "~> 1.0"
gem "druid-tools"
gem "dry-types"
gem "edtf"
gem "faraday", "~> 2.0"
gem "globus_client", "~> 0.10"
gem "honeybadger", "~> 4.0"
gem "jbuilder"
gem "jsbundling-rails", "~> 0.1.9"
gem "lograge", "~> 0.11.2"
gem "okcomputer"
gem "pg"
gem "preservation-client", "~> 6.0"
gem "propshaft"
gem "pry"
gem "redis", "~> 4.0"
# TODO: Deal with this
# pinned because 2.6.0 broke the build: [Reform] Your :populator did not return a Reform::Form instance for `authors`.
gem "reform", "~> 2.5.0"
gem "reform-rails"
gem "rubyzip", "~> 2.3"
gem "sdr-client", "~> 2.0"
gem "sidekiq", "~> 7.0"
gem "sneakers", "~> 2.11" # rabbitMQ background processing
gem "state_machines-activerecord"
gem "turbo-rails", "~> 1.0"
gem "view_component", "~> 2.56.2" # https://github.com/github/view_component/issues/1390
gem "whenever", require: false # Work around https://github.com/javan/whenever/issues/831
gem "zipline", "~> 1.4"
