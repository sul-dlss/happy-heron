# typed: false
# frozen_string_literal: true

# Deposits a Work into SDR API.
class DepositJob < BaseDepositJob
  queue_as :default

  sig { params(work: Work).void }
  def perform(work)
    job_id = deposit(RequestGenerator.generate_model(work: work))
    DepositStatusJob.perform_later(work: work, job_id: job_id)
  rescue StandardError => e
    Honeybadger.notify(e)
  end

  private

  sig { params(request_dro: Cocina::Models::RequestDRO).returns(Integer) }
  def deposit(request_dro)
    login_result = login
    raise login_result.failure unless login_result.success?

    SdrClient::Deposit.model_run(request_dro: request_dro,
                                 # files: [],
                                 url: Settings.sdr_api.url,
                                 logger: Rails.logger,
                                 accession: true)
  end
end
