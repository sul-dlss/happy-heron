# typed: true
# frozen_string_literal: true

module Works
  # Draws a widget for publication and creation dates
  class DatesComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
