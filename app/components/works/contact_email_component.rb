# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for contact emails.
  class ContactEmailComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
