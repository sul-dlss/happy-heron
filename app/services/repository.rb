# frozen_string_literal: true

# Interface to the SDR API
class Repository
  # @return [Cocina::Models::DRO]
  def self.find(druid)
    ensure_logged_in!
    cocina_str = SdrClient::Find.run(druid, url: Settings.sdr_api.url, logger: Rails.logger)
    cocina_json = JSON.parse(cocina_str)
    Cocina::Models.build(cocina_json)
  end

  # @return [boolean] true if H2 version is one greater than SDR version.
  def self.valid_version?(druid:, h2_version:)
    cocina_obj = find(druid)
    cocina_obj.version == h2_version - 1
  end

  def self.ensure_logged_in!
    SdrClientAuthenticator.login
  end
  private_class_method :ensure_logged_in!
end
