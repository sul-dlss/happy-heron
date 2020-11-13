# typed: false
# frozen_string_literal: true

# Form behaviors for EDTF fields
module Edtf
  # Adds a property method that can handle the :edtf and :range options
  module ClassMethods
    def property(name, options = {}, &block)
      if options[:edtf]
        prop_name = name.to_s.delete_suffix('_edtf')
        property "#{prop_name}(1i)", virtual: true
        property "#{prop_name}(2i)", virtual: true
        property "#{prop_name}(3i)", virtual: true

        create_range(prop_name) if options[:range]
      end
      super(name, options, &block)
    end

    def create_range(prop_name)
      property "#{prop_name}_range(1i)", virtual: true
      property "#{prop_name}_range(2i)", virtual: true
      property "#{prop_name}_range(3i)", virtual: true
      property "#{prop_name}_range(4i)", virtual: true
      property "#{prop_name}_range(5i)", virtual: true
      property "#{prop_name}_range(6i)", virtual: true
      property "#{prop_name}_type", virtual: true, default: 'single'
    end
  end

  def self.included(includer)
    includer.extend ClassMethods
  end

  def deserialize!(params)
    super EdtfParamsFilter.new.call(schema, params)
  end
end
