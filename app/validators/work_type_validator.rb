# typed: true
# frozen_string_literal: true

# An ActiveModel validator for work types
class WorkTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if self.class.valid?(value)

    record.errors.add attribute, 'is not a valid work type'
  end

  # Public class method so that it can be called from a controller. We want to
  # validate these on the incoming works/new request before there is a model
  # instance to validate.
  def self.valid?(value)
    value.in?(WorkType.type_list) || value == WorkType.purl_reservation_type.id
  end
end
