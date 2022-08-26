# frozen_string_literal: true

# Draws a bootstrap popover icon.
class PopoverComponent < ApplicationComponent
  def initialize(key:, icon: 'fas fa-info-circle')
    @key = key
    @icon = icon
  end

  attr_reader :icon

  def text
    t(@key, scope: :tooltip)
  end

  def render?
    I18n.exists?("tooltip.#{@key}")
  end
end
