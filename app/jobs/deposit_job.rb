# typed: false
# frozen_string_literal: true

# Deposits a Work into dor-services-app
class DepositJob < ApplicationJob
  queue_as :default

  def perform(work)
    result = api_client.objects.register(params: create_model(work))
    work.update(druid: result.externalIdentifier)
  end

  private

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

  def api_client
    # TODO: maybe SDR client instead
    @api_client ||= Dor::Services::Client.configure(url: Settings.dor_services.url,
                                                    token: Settings.dor_services.token)
  end
end
