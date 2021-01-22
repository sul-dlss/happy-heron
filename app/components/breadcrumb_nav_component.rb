# typed: true
# frozen_string_literal: true

# Displays the top bread crumb navigation
class BreadcrumbNavComponent < ApplicationComponent
  def initialize(breadcrumbs:)
    @breadcrumbs = breadcrumbs || []
  end

  attr_accessor :breadcrumbs
end
