# frozen_string_literal: true

module Works
  # Draws the link to the show page
  class LinkToShowComponent < ApplicationComponent
    def initialize(work_version:)
      @work_version = work_version
    end

    def link
      link_to truncate(title, length: 150, separator: " "), work, title:, class: "work-link"
    end

    def title
      @title ||= WorkTitlePresenter.show(work_version)
    end

    attr_reader :work_version

    delegate :work, to: :work_version
  end
end
