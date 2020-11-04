# typed: true
# frozen_string_literal: true

module Works
  # Allows the user to search for keywords or provide freetext keywords
  class KeywordsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def errors
      helpers.safe_join form.object.errors[:keywords]
    end
  end
end
