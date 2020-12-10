# typed: true
# frozen_string_literal: true

module Collections
  # Renders the tabs for the collection show page
  class WorksComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :allowed_to?, :current_user, :user_with_groups, to: :helpers

    def works
      policy.authorized_scope(collection.works, as: :edits)
    end

    private

    sig { returns(WorkPolicy) }
    def policy
      WorkPolicy.new(user: current_user, user_with_groups: user_with_groups)
    end
  end
end
