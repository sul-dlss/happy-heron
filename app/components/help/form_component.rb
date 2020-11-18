# typed: true
# frozen_string_literal: true

module Help
  # The component that renders the form for contacting us for help
  class FormComponent < ApplicationComponent
    sig { params(user: T.nilable(User)).void }
    def initialize(user:)
      @email = user&.email
      @help_how_value = 'I want to become an SDR depositor' unless user
    end
  end
end
