# frozen_string_literal: true

module Works
  # Renders the widget that allows a reviewer to approve a deposit.
  class ApprovalComponent < ApplicationComponent
    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    def render?
      helpers.allowed_to?(:review?, work_version)
    end

    delegate :work, to: :work_version
  end
end
