# frozen_string_literal: true

# An ActiveModel validator for Embargo release dates
class EmbargoDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    collection = record.model.fetch(:work).collection
    return if collection.blank? || collection.release_duration.blank?

    valid_embargo_value(record, attribute, value) if valid_embargo_collection(collection, record, attribute, value)
  end

  private

  def valid_embargo_collection(collection, record, attribute, value)
    year_match = collection.release_duration.match(/(\d+)/)
    year_label = (year_match[0].to_i < 2) ? "year" : "years"
    future_date = current_date + year_match[0].to_i.years
    error_message = "must be less than #{year_match[0]} #{year_label} in the future"
    if value > future_date
      record.errors.add attribute, error_message
      return false
    end
    true
  end

  def valid_embargo_value(record, attribute, value)
    if value > current_date + 3.years
      record.errors.add attribute, "must be less than 3 years in the future"
    elsif value <= current_date
      record.errors.add attribute, "must be in the future"
    end
  end

  # the current date in the Pacific Time Zone, which is what embargo uses
  #  this is important if you want to ensure that you can set tomorrow's date and it is late in the day pacific
  def current_date
    Time.now.in_time_zone("Pacific Time (US & Canada)").to_date
  end
end
