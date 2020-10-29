# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for describing (abstract, keywords, citation, etc.) a work.
  class DescriptionComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def subtypes
      WorkType.find(form.object.work_type).subtypes
    end
  end
end
