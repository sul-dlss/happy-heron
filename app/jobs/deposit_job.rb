# typed: false
# frozen_string_literal: true

# Deposits a Work into dor-services-app
class DepositJob < ApplicationJob
  extend T::Sig

  queue_as :default

  sig { params(work: Work).void }
  def perform(work)
    job_id = deposit(create_model(work))
    result = nil
    until result
      sleep 1
      result = status(job_id: job_id)
    end
    raise result.failure unless result.success?

    work.druid = result.value!
    work.deposit!
  end

  private

  sig { params(job_id: Integer).returns(T.nilable(Dry::Monads::Result)) }
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def status(job_id:)
    login_result = login
    return login_result unless login_result.success?

    result = SdrClient::BackgroundJobResults.show(url: Settings.sdr_api.url, job_id: job_id)
    if result[:status] != 'complete'
      nil
    elsif result[:output][:errors].present?
      error = result[:output][:errors].first
      error_msg = error[:title]
      error_msg += ": #{error[:message]}" if error[:message]
      Dry::Monads::Failure(error_msg)
    else
      Dry::Monads::Success(result[:output][:druid])
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  sig { params(work: Work).returns(Cocina::Models::RequestDRO) }
  # rubocop:disable Metrics/MethodLength
  def create_model(work)
    Cocina::Models::RequestDRO.new(
      administrative: {
        hasAdminPolicy: 'druid:pq757cd0790' # TODO: What should this be? this is the hydrus APO.
      },
      identification: {
        sourceId: "hydrus:#{work.id}" # TODO: what should this be?
      },
      label: work.title,
      type: Cocina::Models::Vocab.object, # TODO: use something based on worktype
      version: 0
    )
  end
  # rubocop:enable Metrics/MethodLength

  # This allows a login using credentials from the config gem.
  class LoginFromSettings
    def self.run
      { email: Settings.sdr_api.email, password: Settings.sdr_api.password }
    end
  end

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

  sig { returns(Dry::Monads::Result) }
  def login
    SdrClient::Login.run(url: Settings.sdr_api.url, login_service: LoginFromSettings)
  end
end
