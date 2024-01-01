# frozen_string_literal: true

# Form behaviors for EmbargoDate fields
module EmbargoDate
  # Adds a property method that can handle the :embargo_date
  module ClassMethods
    def property(prop_name, options = {}, &)
      if options[:embargo_date]
        property "#{prop_name}(1i)", virtual: true, default: Time.zone.today.year
        property "#{prop_name}(2i)", virtual: true
        property "#{prop_name}(3i)", virtual: true
      end
      super(prop_name, options, &)
    end
  end

  def self.included(includer)
    includer.extend ClassMethods
  end

  def deserialize!(params)
    super(EmbargoDateParamsFilter.new.call(schema, params))
  end
end
