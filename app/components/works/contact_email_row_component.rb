# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for describing a related link.
  class ContactEmailRowComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    sig { returns(T::Boolean) }
    def not_first_email?
      form.index != 0
    end
  end
end
