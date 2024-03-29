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

    def errors
      form.object.errors.where(:keywords)
    end

    def row(keyword_form)
      render Works::KeywordsRowComponent.new(form: keyword_form)
    end
  end
end
