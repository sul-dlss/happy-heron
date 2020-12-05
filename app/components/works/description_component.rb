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
      WorkType.subtypes_for(work_type)
    end

    def work_type
      form.object.work_type
    end

    def other_type?
      work_type == 'other'
    end

    def sanitized_value(value)
      # This is how the rails check_box tag with multiple values creates its labels:
      ActionView::Helpers::Tags::Base.new(nil, nil, nil).send(:sanitized_value, value)
    end
  end
end
