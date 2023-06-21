# frozen_string_literal: true

# Authenticate SDR client connections
class SdrClientAuthenticator
  # This allows a login using credentials from the config gem.
  class LoginFromSettings
    def self.run
      {email: Settings.sdr_api.email, password: Settings.sdr_api.password}
    end
  end

  def self.login
    SdrClient::Login.run(url: Settings.sdr_api.url, login_service: LoginFromSettings)
  end
end
