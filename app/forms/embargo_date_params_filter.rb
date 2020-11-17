# typed: true
# frozen_string_literal: true

# Responsible for deserializing the form inputs into Date values
class EmbargoDateParamsFilter
  def call(schema, params)
    date_attributes = {}
    schema.each do |dfn|
      next unless dfn[:embargo_date]

      name = dfn[:name]
      date_attributes[name] = deserialize(params, name) if dfn[:assign_if].call(params)
    end

    params.merge(date_attributes)
  end

  def deserialize(params, date_attribute)
    year = params.delete("#{date_attribute}(1i)").to_i
    month = params.delete("#{date_attribute}(2i)").to_i
    day = params.delete("#{date_attribute}(3i)").to_i
    Date.new(year, month, day)
  end
end
