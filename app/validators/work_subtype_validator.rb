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
    subtypes = Array(value)

    case work_type
    when WorkType::OTHER
      # A subtype is required for the "other" work type and the value
      # must merely be present
      return subtypes.first.present?
    when WorkType::MUSIC
      # A subtype is required for the "music" work type and at least one
      # must come from a defined list
      return false if subtypes.count { |subtype| subtype.in?(WorkType.subtypes_for(work_type)) } <
                      WorkType::MINIMUM_REQUIRED_MUSIC_SUBTYPES
    when WorkType::MIXED_MATERIAL
      # At least two subtypes ared required for the "mixed material" work type
      return false if subtypes.count < WorkType::MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES
    end

    # NOTE: this also handles the case when `value` is `nil` correctly: returning `true`
    subtypes.all? { |subtype| subtype.in?(WorkType.subtypes_for(work_type, include_more_types: true)) }
  rescue WorkType::InvalidType
    false
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end
