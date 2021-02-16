# typed: false
# frozen_string_literal: true

# Draws a bootstrap popover icon.
class PopoverComponent < ApplicationComponent
  def initialize(key:)
    @key = key
  end

  def text
    t(@key, scope: :tooltip)
  end

  def render?
    I18n.exists?("tooltip.#{@key}")
  end
end
