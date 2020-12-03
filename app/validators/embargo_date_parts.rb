# typed: true
# frozen_string_literal: true

# Validates embargo month and day
class EmbargoDateParts < ActiveModel::Validator
  def validate(record)
    return if record.send('embargo_date').instance_of?(Date)

    month = record.send('embargo_date(2i)')
    day = record.send('embargo_date(3i)')
    record.errors.add('embargo-date', 'Must provide all parts') if month.nil? || day.nil?
  end
end
