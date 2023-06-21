# frozen_string_literal: true

# Validates created date interval
class CreatedDateParts < ActiveModel::Validator
  def validate(record)
    start_year = record.send(:"created_range(1i)")
    finish_year = record.send(:"created_range(4i)")

    return if start_year.blank? && finish_year.blank?
    return if start_year.present? && finish_year.present?

    record.errors.add(:created_date_range_start, "must be provided") if start_year.blank?
    record.errors.add(:created_date_range_end, "must be provided") if finish_year.blank?
  end
end
