# typed: false
# frozen_string_literal: true

module Dashboard
  # Renders a collection and a summary table of works in the collection
  class CollectionComponent < ApplicationComponent
    MAX_DEPOSITS_TO_SHOW = 4

    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :current_user, :user_with_groups, to: :helpers

    sig { returns(ActiveRecord::Relation) }
    def visible_deposits
      # This component only displays MAX_DEPOSITS_TO_SHOW works but we query for
      # one more as a way to flag to the user that they should click through to
      # the collection works page to see more. We could query for the four
      # displayable works and add another query to get the overall count, but
      # that would double the number of queries run for each instance of this
      # component.
      collection.works.order('updated_at desc').limit(MAX_DEPOSITS_TO_SHOW + 1)
    end

    private

    sig { returns(WorkPolicy) }
    def policy
      WorkPolicy.new(user: current_user, user_with_groups: user_with_groups)
    end
  end
end
