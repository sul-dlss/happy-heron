# typed: true
# frozen_string_literal: true

module Dashboard
  # Renders a list of collections in progress
  class InProgressCollectionComponent < ApplicationComponent
    sig { params(presenter: DashboardPresenter).void }
    def initialize(presenter:)
      @presenter = presenter
    end

    attr_reader :presenter

    delegate :collection_managers_in_progress, to: :presenter
    delegate :user_with_groups, to: :helpers

    sig { returns(T::Boolean) }
    def render?
      user_with_groups.administrator? || collection_managers_in_progress.present?
    end
  end
end
