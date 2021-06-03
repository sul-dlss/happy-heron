# typed: true
# frozen_string_literal: true

# Validates embargo month and day
class EmbargoDateParts < ActiveModel::Validator
  def validate(record)
    # If we've already successfully deserialized the date, there's no point to continuing
    return if record.embargo_date.instance_of?(Date)

    # Adds error because embargo date is nil (may be missing month and day values in form)
    record.errors.add(:embargo_date, 'must provide all parts')
  end
end
