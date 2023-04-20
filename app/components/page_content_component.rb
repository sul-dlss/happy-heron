# frozen_string_literal: true

# Renders an optional user message on the selected page
class PageContentComponent < ApplicationComponent
  def initialize(page_content:)
    @page_content = page_content
  end

  attr_reader :page_content

  def render?
    page_content.present? && page_content.visible
  end
end
