# frozen_string_literal: true

module Dashboard
  # Renders an optional user message on the dashboard page
  class PageContentComponent < ApplicationComponent
    def initialize(page_content:)
      @page_content = page_content
    end

    attr_reader :page_content

    def render?
      page_content.present? && page_content.visible
    end
  end
end
