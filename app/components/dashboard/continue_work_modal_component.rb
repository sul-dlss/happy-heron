# typed: true
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

    def work_version
      @presenter.in_progress.first
    end

    delegate :work, to: :work_version

    def title
      @title ||= WorkTitlePresenter.show(work_version)
    end
  end
end
