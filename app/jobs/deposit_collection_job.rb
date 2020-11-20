# typed: false
# frozen_string_literal: true

# Deposits a Collection into SDR API.
class DepositCollectionJob < BaseDepositJob
  queue_as :default

  sig { params(collection: Collection).void }
  def perform(collection)
    collection.update(version: collection.version + 1)

    job_id = deposit(request_dro: CollectionGenerator.generate_model(collection: collection))
    DepositStatusJob.perform_later(object: collection, job_id: job_id)
  rescue StandardError => e
    Honeybadger.notify(e)
  end

  private

  sig do
    params(request_dro: T.any(Cocina::Models::RequestCollection, Cocina::Models::Collection))
      .returns(Integer)
  end
  def deposit(request_dro:)
    login_result = login

    raise login_result.failure unless login_result.success?

    create_or_update(request_dro)
  end

  sig { params(request_dro: T.any(Cocina::Models::RequestCollection, Cocina::Models::Collection)).returns(Integer) }
  def create_or_update(request_dro)
    case request_dro
    when Cocina::Models::RequestCollection
      SdrClient::Deposit::CreateResource.run(accession: true,
                                             metadata: request_dro,
                                             logger: Rails.logger,
                                             connection: connection)
    when Cocina::Models::Collection
      SdrClient::Deposit::UpdateResource.run(metadata: request_dro,
                                             logger: Rails.logger,
                                             connection: connection)
    end
  end

  sig { returns(SdrClient::Connection) }
  def connection
    @connection ||= SdrClient::Connection.new(url: Settings.sdr_api.url)
  end
end
