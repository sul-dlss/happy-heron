# frozen_string_literal: true

# Deposits a Collection into SDR API.
class DepositCollectionJob < ApplicationJob
  queue_as :default

  def perform(collection_version)
    collection_model = CocinaGenerator::CollectionGenerator.generate_model(collection_version:)
    version_description = collection_version.version_description.presence

    case collection_model
    when Cocina::Models::RequestCollection
      # TODO: Consider removing `basepath` as a required arg in sdr-client since it's useless without files
      SdrClient::RedesignedClient.deposit_model(
        model: collection_model,
        accession: true,
        basepath: '.'
      )
    when Cocina::Models::Collection
      SdrClient::RedesignedClient.update_model(model: collection_model,
                                               version_description:)
    end
  rescue StandardError => e
    Honeybadger.notify(e)
  end
end
