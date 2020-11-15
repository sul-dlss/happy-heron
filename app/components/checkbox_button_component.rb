# typed: true
# frozen_string_literal: true

# A widget to style radio buttons look like large buttons
class CheckboxButtonComponent < ApplicationComponent
  def initialize(name:, value:, data: nil)
    @name = name
    @value = value
    @data = data
  end

  attr_reader :name, :value, :data

  def id
    value.dasherize
  end

  def check
    '✓'
  end

  def uncheck
    ''
  end
end
