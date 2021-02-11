# typed: true
# frozen_string_literal: true

# An ActiveModel validator for work subtypes
class WorkSubtypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if self.class.valid?(record.work_type, value)

    record.errors.add attribute, "is not a valid subtype for work type #{record.work_type}"
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # Public class method so that it can be called from a controller. We want to
  # validate these on the incoming works/new request before there is a model
  # instance to validate.
  def self.valid?(work_type, value)
    # A subtype is required for the "other" work type and the value must merely be present
    return Array(value).first.present? if work_type == 'other'

    # A subtype is required for the "music" work type and at least one must come from a defined list
    if work_type == 'music'
      return value.present? &&
             value.any? { |subtype| subtype.in?(WorkType.subtypes_for(work_type)) }
    end

    return true if value.nil?

    value.all? { |subtype| subtype.in?(WorkType.subtypes_for(work_type, include_more_types: true)) }
  rescue WorkType::InvalidType
    false
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
