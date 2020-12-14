# typed: false
# frozen_string_literal: true

DeviseRemoteUser.configure do |config|
  config.env_key = lambda do |env|
    if Rails.env.development? && ENV['REMOTE_USER']
      ENV['REMOTE_USER']
    else
      # Return the first non-blank value of a remote user header, or return nil (unauthenticated)
      env.to_h.values_at(*Settings.remote_user_headers).find(&:present?).presence
    end
  end
  config.logout_url = '/Shibboleth.sso/Logout'
  config.auto_create = true
  config.auto_update = true
  config.attribute_map = { name: Settings.name_header }
end
