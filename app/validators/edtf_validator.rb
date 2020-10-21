# typed: true
# frozen_string_literal: true

class EdtfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless EDTF.parse(value).nil?

    record.errors[attribute] << 'is not valid EDTF'
  end
end
