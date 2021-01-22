# typed: false
# frozen_string_literal: true

module Works
  # Allows the user to search for keywords or provide freetext keywords
  class KeywordsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def error?
      errors.present?
    end

    def error_message
      safe_join(errors.map(&:message), tag.br)
    end

    def errors
      form.object.errors.where(:keywords)
    end
  end
end
