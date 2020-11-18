# typed: true
# frozen_string_literal: true

module Works
  # Renders the widget that allows a reviewer to approve a deposit.
  class ApprovalComponent < ApplicationComponent
    sig { params(work: Work).void }
    def initialize(work:)
      @work = work
    end

    attr_reader :work

    sig { returns(T::Boolean) }
    def render?
      helpers.allowed_to?(:review?, work)
    end
  end
end
