# typed: strict
# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: Settings.redis_url }
  ActiveRecord::Base.logger = Sidekiq.logger
  Rails.logger = Sidekiq.logger
end

Sidekiq.configure_client do |config|
  config.redis = { url: Settings.redis_url }
end
