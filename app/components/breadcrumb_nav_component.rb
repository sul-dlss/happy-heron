# frozen_string_literal: true

# Displays the top bread crumb navigation
class BreadcrumbNavComponent < ApplicationComponent
  def initialize(breadcrumbs: [])
    @orig_breadcrumbs = breadcrumbs
  end

  def full_title(breadcrumb)
    breadcrumb.presence || 'No title'
  end

  def truncated_title(breadcrumb)
    truncate(full_title(breadcrumb), length: 150, separator: ' ')
  end

  def title_from_breadcrumbs
    title_breadcrumbs = (orig_breadcrumbs.presence || [{ title: 'Dashboard' }]).reject do |breadcrumb|
      breadcrumb[:omit_title]
    end
    title_breadcrumbs
      .pluck(:title)
      .compact
      .unshift('SDR')
      .join(' | ')
  end

  def breadcrumbs
    [{ title: 'Dashboard', link: '/dashboard' }] + orig_breadcrumbs
  end

  private

  attr_accessor :orig_breadcrumbs
end
