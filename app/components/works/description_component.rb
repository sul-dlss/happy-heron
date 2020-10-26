# typed: true
# frozen_string_literal: true

module Works
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
