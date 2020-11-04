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
      WorkType.subtypes_for(form.object.work_type)
    end
  end
end
