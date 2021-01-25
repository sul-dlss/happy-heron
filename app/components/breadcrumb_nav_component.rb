# typed: true
# frozen_string_literal: true

# Displays the top bread crumb navigation
class BreadcrumbNavComponent < ApplicationComponent
  def initialize(breadcrumbs: [], show_dashboard: true, confirm_dashboard: false)
    @breadcrumbs = breadcrumbs
    @breadcrumbs.unshift({ title: 'Dashboard', link: '/dashboard', confirm: confirm_dashboard }) if show_dashboard
  end

  attr_accessor :breadcrumbs
end
