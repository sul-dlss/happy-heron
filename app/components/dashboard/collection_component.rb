# typed: true
# frozen_string_literal: true

module Dashboard
  # Renders a collection and a summary table of works in the collection
  class CollectionComponent < ApplicationComponent
    MAX_DEPOSITS_TO_SHOW = 4

    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    delegate :allowed_to?, :current_user, :user_with_groups, to: :helpers

    sig { returns(String) }
    def name
      collection.name.presence || 'No Title'
    end

    sig { returns(ActiveRecord::Relation) }
    def visible_deposits
      policy.authorized_scope(collection.works.limit(MAX_DEPOSITS_TO_SHOW), as: :edits)
    end

    sig { returns(Integer) }
    def total_deposits_count
      policy.authorized_scope(collection.works, as: :edits).count
    end

    private

    sig { returns(WorkPolicy) }
    def policy
      WorkPolicy.new(user: current_user, user_with_groups: user_with_groups)
    end
  end
end
