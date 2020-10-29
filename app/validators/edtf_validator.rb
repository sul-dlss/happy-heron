# typed: true
# frozen_string_literal: true

# An ActiveModel validator for EDTF formatted dates
class EdtfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? || EDTF.parse(value)

    record.errors[attribute] << 'is not valid EDTF'
  end
end
