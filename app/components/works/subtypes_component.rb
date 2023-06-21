# frozen_string_literal: true

module Works
  # Allows the user to specify work subtypes
  class SubtypesComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def work_type
      form.object.work_type
    end

    def other_type?
      work_type == "other"
    end

    def music_type?
      work_type == "music"
    end

    def mixed_material_type?
      work_type == "mixed material"
    end

    def optional?
      !work_type.in?(["mixed material", "music", "other"])
    end

    def subtypes
      WorkType.subtypes_for(work_type)
    end

    def more_types
      WorkType.more_types - subtypes - [work_type.titlecase]
    end

    def tooltip
      return if work_type == "other"

      key = "work.subtypes."
      key += case work_type
      when "music"
        "music"
      when "mixed material"
        "mixed"
      else
        "default"
      end
      render PopoverComponent.new key:
    end

    def sanitized_value(value)
      # This is how the rails check_box tag with multiple values creates its labels:
      ActionView::Helpers::Tags::Base.new(nil, nil, nil).send(:sanitized_value, value)
    end
  end
end
