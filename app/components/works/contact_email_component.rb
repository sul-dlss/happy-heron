# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for contact emails.
  class ContactEmailComponent < ApplicationComponent
    def initialize(form:, key:)
      @form = form
      @key = key
    end

    attr_reader :form, :key

    def row(email_form)
      render Works::ContactEmailRowComponent.new(form: email_form, key: key)
    end
  end
end
