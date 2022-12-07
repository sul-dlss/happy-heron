# frozen_string_literal: true

GlobusClient.configure(
  client_id: Settings.globus.client_id,
  client_secret: Settings.globus.client_secret,
  uploads_directory: Settings.globus.uploads_directory,
  transfer_endpoint_id: Settings.globus.transfer_endpoint_id
)
