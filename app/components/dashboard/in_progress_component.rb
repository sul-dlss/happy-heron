# frozen_string_literal: true

module Dashboard
  # Renders a list of works in progress
  class InProgressComponent < ApplicationComponent
    def initialize(presenter:)
      @presenter = presenter
    end

    attr_reader :presenter

    delegate :in_progress, to: :presenter
  end
end
