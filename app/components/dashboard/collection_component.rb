# typed: true
# frozen_string_literal: true

module Dashboard
  # Renders a collection and a summary table of works in the collection
  class CollectionComponent < ApplicationComponent
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
    def deposits
      policy = WorkPolicy.new(user: current_user, user_with_groups: user_with_groups)
      policy.authorized_scope(collection.works.limit(5), as: :depositor)
    end
  end
end
