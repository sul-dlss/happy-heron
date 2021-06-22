# typed: true
# frozen_string_literal: true

# An ActiveModel validator for EDTF formatted dates
class CreatedInPastValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    case value
    when Date
      validate_date(record, attribute, value)
    when EDTF::Interval
      validate_date(record, attribute, value.from, 'start')
      validate_date(record, attribute, value.to, 'end')
      validate_interval_order(record, value)
    end
  end

  private

  def validate_date(record, attribute, value, prefix = nil)
    prefix &&= "#{prefix} "
    record.errors.add(attribute, "#{prefix}must have a four digit year") if Settings.earliest_year > value.year
    record.errors.add(attribute, "#{prefix}must be in the past") if Time.zone.today < value
  end

  def validate_interval_order(record, value)
    return if value.from < value.to

    record.errors.add(:created_date_range_start, 'must be before end')
  end
end
