# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for setting the title and contact for the work.
  class TitleComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
