# typed: true
# frozen_string_literal: true

module Works
  # Allows the user to search for keywords or provide freetext keywords
  class SelectedKeywordComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def label_id
      form.object.id
    end
  end
end
