# frozen_string_literal: true

# Draws a bootstrap popover icon.
# When rendering the PopoverComponent, add a "aria-describedby" attribute to
#  the element described by the popover with a value of "popover-KEY",
#  where KEY is the value of the key passed to the PopoverComponent, e.g.:
#  <legend aria-describedby="popover-collection.depositors">Depositors</legend>
#  <%= render PopoverComponent.new key: "collection.depositors" %>
class PopoverComponent < ApplicationComponent
  def initialize(key:, icon: 'fa-solid fa-info-circle', scope: 'tooltip', custom_content: nil)
    @key = key
    @icon = icon
    @scope = scope
    @custom_content = custom_content
  end

  attr_reader :custom_content, :icon, :scope, :key

  def text
    custom_content || t(key, scope:)
  end

  def render?
    I18n.exists?("#{scope}.#{key}")
  end
end
