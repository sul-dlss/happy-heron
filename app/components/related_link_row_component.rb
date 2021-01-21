# typed: true
# frozen_string_literal: true

# Renders a widget for describing a related link.
class RelatedLinkRowComponent < ApplicationComponent
  def initialize(form:)
    @form = form
  end

  attr_reader :form
end
