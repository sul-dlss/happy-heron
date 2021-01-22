# typed: false
# frozen_string_literal: true

# Displays the top bread crumb navigation
class BreadcrumbNavComponent < ApplicationComponent
  def initialize(breadcrumbs:)
    @breadcrumbs = breadcrumbs
  end

  def breadcrumb_links
    @breadcrumbs.map do |breadcrumb|
      if breadcrumb[:link].empty?
        breadcrumb[:title]
      else
        link_to breadcrumb[:title].presence || 'No title', breadcrumb[:link], class: 'breadcrumb-link'
      end
    end
  end
end
