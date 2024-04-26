# frozen_string_literal: true

# Register a DRUID in the SDR API.
class ReserveJob < ApplicationJob
  queue_as :default

  def perform(work_version)
    request_dro = CocinaGenerator::DROGenerator.generate_model(work_version:)

    # TODO: Consider removing `basepath` as a required arg in sdr-client since it's useless without files
    SdrClient::RedesignedClient.deposit_model(
      model: request_dro,
      accession: false,
      basepath: '.'
    )
  end
end
