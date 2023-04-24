# frozen_string_literal: true

module Dashboard
  # Renders an optional user message on the dashboard page
  class PageContentComponent < ApplicationComponent
    def initialize(page_content:, location:)
      @page_content = page_content
      @location = location
    end

    attr_reader :page_content, :location

    def render?
      page_content.present? && page_content.visible
    end
  end
end
