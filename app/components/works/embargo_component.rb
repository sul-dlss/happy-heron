# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for defining an embargo on a work.
  class EmbargoComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
