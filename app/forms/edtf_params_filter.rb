# frozen_string_literal: true

# Responsible for deserializing the form inputs into edtf values
class EdtfParamsFilter
  def call(schema, params)
    date_attributes = {}
    schema.each do |dfn|
      next unless dfn[:edtf]

      name = dfn[:name].delete_suffix('_edtf')

      date_attributes[dfn[:name]] = deserialize(params, name, dfn[:range] && params["#{name}_type"] == 'range')
    end
    params.merge(date_attributes)
  end

  def deserialize(params, name, range)
    EDTF.parse(range ? deserialize_edtf_range(params, name) : deserialize_edtf(params, name))
  end

  def deserialize_edtf(params, date_attribute, offset = 0)
    year = params["#{date_attribute}(#{1 + offset}i)"]
    month = params["#{date_attribute}(#{2 + offset}i)"]
    day = params["#{date_attribute}(#{3 + offset}i)"]
    approximate = params["#{date_attribute}(approx#{offset})"]

    deserialize_edtf_date(year, month, day, approximate)
  end

  def deserialize_edtf_range(params, name)
    range_name = "#{name}_range"
    start = deserialize_edtf(params, range_name)
    finish = deserialize_edtf(params, range_name, 3)
    return unless start && finish

    # Slash is the range separator in EDTF
    [start, finish].join('/')
  end

  def deserialize_edtf_date(year, month, day, approximate)
    return if year.blank?

    date = year.dup
    if month.present?
      date += "-#{format('%<month>02d', month:)}"
      date += "-#{format('%<day>02d', day:)}" if day.present?
    end
    date += '~' if approximate
    date
  end
end
