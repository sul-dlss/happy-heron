# typed: true
# frozen_string_literal: true

module Dashboard
  # Renders a collection and a summary table of works in the collection
  class ApprovalsComponent < ApplicationComponent
    sig { params(presenter: DashboardPresenter).void }
    def initialize(presenter:)
      @presenter = presenter
    end

    attr_reader :presenter

    delegate :approvals, to: :presenter

    def render?
      approvals.any?
    end
  end
end
