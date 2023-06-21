# frozen_string_literal: true

require_relative "boot"

require "action_cable/engine"
require "action_controller/railtie"
# require 'action_mailbox/engine'
require "action_mailer/railtie"
# require 'action_text/engine'
require "action_view/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HappyHeron
  # The applications configuration
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't bother running AS analyzers since we handle technical metadata elsewhere
    config.active_storage.analyzers = []

    # Use SQL schema format so we can have nice things like Postgres enums
    config.active_record.schema_format = :sql

    # Mount the ActionCable server at a known path
    config.action_cable.mount_path = "/cable"

    config.action_mailer.default_url_options = {host: Settings.host}
    config.action_mailer.perform_deliveries = Settings.perform_deliveries

    # Override the default (5.minutes), so that large files have enough time to upload
    # Currently 90 minutes is based on most 10G uploads on slow connections taking just under 1.5 hours
    config.active_storage.service_urls_expire_in = 90.minutes

    console do
      Honeybadger.configure do |config|
        config.report_data = false
      end
    end
  end
end
