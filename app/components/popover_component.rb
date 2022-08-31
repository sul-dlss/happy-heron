# frozen_string_literal: true

# Draws a bootstrap popover icon.
class PopoverComponent < ApplicationComponent
  def initialize(key:, icon: 'fa-solid fa-info-circle', scope: 'tooltip')
    @key = key
    @icon = icon
    @scope = scope
  end

  attr_reader :icon, :scope

  def text
    t(@key, scope: scope)
  end

  def render?
    I18n.exists?("#{scope}.#{@key}")
  end
end
