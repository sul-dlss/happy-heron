# frozen_string_literal: true

module Dashboard
  # Renders an Admin Dashboard button
  class AdminButtonComponent < ApplicationComponent
    delegate :allowed_to?, to: :helpers

    def render?
      allowed_to?(:show?, :admin_dashboard)
    end
  end
end
