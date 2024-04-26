# frozen_string_literal: true

# Interface to the SDR API
class Repository
  # @return [Cocina::Models::DRO]
  def self.find(druid)
    cocina_hash = SdrClient::RedesignedClient.find(object_id: druid)
    Cocina::Models.build(cocina_hash)
  end

  # @return [boolean] true if H2 version is one greater than SDR version.
  def self.valid_version?(druid:, h2_version:)
    cocina_obj = find(druid)

    # This is the same logic as SDR API.
    allowed_versions = [cocina_obj.version, cocina_obj.version + 1]
    allowed_versions.include?(h2_version)
  end
end
