# frozen_string_literal: true

# Interface to the SDR API
class Repository
  # @return [Cocina::Models::DRO]
  def self.find(druid)
    cocina_str = SdrClient::Find.run(druid, url: Settings.sdr_api.url, logger: Rails.logger)
    cocina_json = JSON.parse(cocina_str)
    Cocina::Models.build(cocina_json)
  end
end
