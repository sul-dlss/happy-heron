# frozen_string_literal: true

# Responsible for deserializing the form inputs into Date values
class EmbargoDateParamsFilter
  def call(schema, params)
    date_attributes = {}
    schema.each do |dfn|
      next unless dfn[:embargo_date]

      name = dfn[:name]
      date_attributes[name] = if params.slice(*release_params).values.include?('immediate') # rubocop:disable Performance/InefficientHashSearch
                                nil # Do not attempt to deserialize date if release is immediate
                              else
                                deserialize(params, name)
                              end
    end

    params.merge(date_attributes)
  end

  def deserialize(params, date_attribute)
    year = params["#{date_attribute}(1i)"].to_i
    month = params["#{date_attribute}(2i)"].to_i
    day = params["#{date_attribute}(3i)"].to_i
    Date.new(year, month, day) if Date.valid_date?(year, month, day)
  end

  private

  # Work and Collection models use differently named release params
  def release_params
    %w[release release_option]
  end
end
