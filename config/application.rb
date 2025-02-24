# frozen_string_literal: true

require_relative 'boot'

# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require 'action_mailbox/engine'
# require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HappyHeron
  # The applications configuration
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Add timestamps to all loggers (both Rack-based ones and e.g. Sidekiq's)
    config.log_formatter = proc do |severity, datetime, _progname, msg|
      "[#{datetime.to_fs(:iso8601)}] [#{severity}] #{msg}\n"
    end

    # Don't bother running AS analyzers since we handle technical metadata elsewhere
    config.active_storage.analyzers = []

    # Use SQL schema format so we can have nice things like Postgres enums
    config.active_record.schema_format = :sql

    # Mount the ActionCable server at a known path
    config.action_cable.mount_path = '/cable'

    config.action_mailer.default_url_options = { host: Settings.host }
    config.action_mailer.perform_deliveries = Settings.perform_deliveries

    # Override the default (5.minutes), so that large files have enough time to upload
    # Currently 90 minutes is based on most 10G uploads on slow connections taking just under 1.5 hours
    config.active_storage.service_urls_expire_in = 90.minutes

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = 'Central Time (US & Canada)'
    # config.eager_load_paths << Rails.root.join('extras')

    console do
      Honeybadger.configure do |config|
        config.report_data = false
      end
    end
  end
end
