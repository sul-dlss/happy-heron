# frozen_string_literal: true

require 'sdr_client'
require 'sdr_client/redesigned_client' # TODO: Remove this when the redesigned client is promoted

# Configure SDR client
SdrClient::RedesignedClient.configure(
  url: Settings.sdr_api.url,
  email: Settings.sdr_api.email,
  password: Settings.sdr_api.password,
  logger: Rails.logger
)
