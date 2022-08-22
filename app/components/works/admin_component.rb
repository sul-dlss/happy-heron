# frozen_string_literal: true

module Works
  # Renders the admin functions for a work
  class AdminComponent < ApplicationComponent
    def initialize(work:)
      @work = work
    end

    attr_reader :work

    def render?
      helpers.user_with_groups.administrator?
    end
  end
end
