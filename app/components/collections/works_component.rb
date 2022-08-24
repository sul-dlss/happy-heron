# frozen_string_literal: true

module Collections
  # Renders the tabs for the collection show page
  class WorksComponent < ApplicationComponent
    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    delegate :current_user, :user_with_groups, to: :helpers

    def works
      policy.authorized_scope(collection.works, as: :edits, with: WorkVersionPolicy)
            .order('works.updated_at DESC')
    end

    def hide_depositor?
      !collection_policy.review?
    end

    private

    def policy
      WorkVersionPolicy.new(user: current_user, user_with_groups: user_with_groups)
    end

    def collection_policy
      CollectionPolicy.new(collection, user: current_user, user_with_groups: user_with_groups)
    end
  end
end
