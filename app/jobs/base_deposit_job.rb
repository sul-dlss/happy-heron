# frozen_string_literal: true

# Base class for Deposit jobs.
class BaseDepositJob < ApplicationJob
  protected

  # This allows a login using credentials from the config gem.
  class LoginFromSettings
    def self.run
      { email: Settings.sdr_api.email, password: Settings.sdr_api.password }
    end
  end

  def login
    SdrClient::Login.run(url: Settings.sdr_api.url, login_service: LoginFromSettings)
  end
end
