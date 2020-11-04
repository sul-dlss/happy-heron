# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for describing a list of related works.
  class RelatedWorkComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
