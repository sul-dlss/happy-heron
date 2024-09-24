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
    number, span = collection.release_duration
                             .match(/(?<number>\d+) (?<span>\w+)/)
                             .named_captures
                             .values_at('number', 'span')
    embargo_date = current_date + number.to_i.public_send(span)
    return true if value <= embargo_date

    record.errors.add(attribute, "must be less than #{number} #{span} in the future")
    false
  end

  def valid_embargo_value(record, attribute, value)
    if value > current_date + 3.years
      record.errors.add attribute, 'must be less than 3 years in the future'
    elsif value <= current_date
      record.errors.add attribute, 'must be in the future'
    end
  end

  # the current date in the Pacific Time Zone, which is what embargo uses
  #  this is important if you want to ensure that you can set tomorrow's date and it is late in the day pacific
  def current_date
    Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
  end
end
