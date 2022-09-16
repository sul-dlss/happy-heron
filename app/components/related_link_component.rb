# frozen_string_literal: true

# Renders a widget for describing a list of related links.
class RelatedLinkComponent < ApplicationComponent
  def initialize(form:, key:)
    @form = form
    @key = key
  end

  attr_reader :form, :key

  def tooltip
    render PopoverComponent.new key:
  end
end
