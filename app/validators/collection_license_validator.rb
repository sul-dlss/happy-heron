# frozen_string_literal: true

# Validates collection license options
class CollectionLicenseValidator < ActiveModel::Validator
  def validate(record)
    # One or the other must be present
    return if record.required_license.in?(License.license_list) ||
      record.default_license.in?(License.license_list)

    record.errors.add(:license, "Either a required license or a default license must be present")
  end
end
