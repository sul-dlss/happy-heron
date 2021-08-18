# frozen_string_literal: true

# Renders a widget for describing a related link.
class RelatedLinkRowComponent < ApplicationComponent
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  delegate :link_title, to: :model_instance

  def model_instance
    form.object
  end
end
