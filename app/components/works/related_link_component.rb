# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for describing a list of related links.
  class RelatedLinkComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
