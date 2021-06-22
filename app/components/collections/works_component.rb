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

    delegate :current_user, :user_with_groups, to: :helpers

    def works
      policy.authorized_scope(collection.works, as: :edits, with: WorkVersionPolicy)
            .order('updated_at DESC')
    end

    sig { returns(T::Boolean) }
    def hide_depositor?
      !(user_with_groups.administrator? ||
        collection.managed_by.include?(current_user) ||
        collection.reviewed_by.include?(current_user))
    end

    private

    sig { returns(WorkVersionPolicy) }
    def policy
      WorkVersionPolicy.new(user: current_user, user_with_groups: user_with_groups)
    end
  end
end
