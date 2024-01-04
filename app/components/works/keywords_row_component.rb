# frozen_string_literal: true

module Works
  # Allows the user to search for keywords or provide freetext keywords
  class KeywordsRowComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def keyword_remove_label
      "Remove #{form.object.label || 'blank keyword'}"
    end

    def error?
      errors.present?
    end

    def errors
      form.object.errors.where(:keywords)
    end
  end
end
