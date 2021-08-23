# frozen_string_literal: true

# Register a DRUID in the SDR API.
class ReserveJob < BaseDepositJob
  queue_as :default

  def perform(work_version)
    login_result = login
    raise login_result.failure unless login_result.success?

    request_dro = CocinaGenerator::DROGenerator.generate_model(work_version: work_version)
    SdrClient::Deposit::CreateResource.run(accession: false,
                                           metadata: request_dro,
                                           logger: Rails.logger,
                                           connection: connection)
  end

  def connection
    @connection ||= SdrClient::Connection.new(url: Settings.sdr_api.url)
  end
end
