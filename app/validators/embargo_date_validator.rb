# typed: true
# frozen_string_literal: true

# An ActiveModel validator for Embargo release dates
class EmbargoDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    return if value <= Time.zone.today + 3.years

    record.errors[attribute] << 'Must be less than 3 years in the future'
  end
end
