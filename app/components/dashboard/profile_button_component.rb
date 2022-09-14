# frozen_string_literal: true

module Dashboard
  # display the link to the profile page
  class ProfileButtonComponent < ApplicationComponent
    delegate :allowed_to?, to: :helpers

    def render?
      allowed_to?(:show?, :profile)
    end
  end
end
