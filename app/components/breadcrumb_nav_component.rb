# typed: false
# frozen_string_literal: true

# Displays the top bread crumb navigation
class BreadcrumbNavComponent < ApplicationComponent
  def initialize(breadcrumbs: [], show_dashboard: true)
    @breadcrumbs = breadcrumbs
    @breadcrumbs.unshift({ title: 'Dashboard', link: '/dashboard' }) if show_dashboard
  end

  sig { params(breadcrumb: T.nilable(String)).returns(T.nilable(String)) }
  def full_title(breadcrumb)
    breadcrumb.presence || 'No title'
  end

  sig { params(breadcrumb: T.nilable(String)).returns(T.nilable(String)) }
  def truncated_title(breadcrumb)
    truncate(full_title(breadcrumb), length: 150, separator: ' ')
  end

  attr_accessor :breadcrumbs
end
