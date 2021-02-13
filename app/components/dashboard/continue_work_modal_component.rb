# typed: false
# frozen_string_literal: true

module Dashboard
  # Display a modal prompting the user to see if they want to continue a deposit in progress
  class ContinueWorkModalComponent < ApplicationComponent
    def initialize(presenter:)
      @presenter = presenter
    end

    def render?
      @presenter.show_popup?
    end

    def work
      @presenter.in_progress.first
    end

    delegate :title, to: :work
  end
end
