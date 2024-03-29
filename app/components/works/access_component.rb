# frozen_string_literal: true

module Works
  # Renders a widget for specifying the access level on a work.
  class AccessComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
