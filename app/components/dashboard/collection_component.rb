# frozen_string_literal: true

module Dashboard
  # Renders a collection and a summary table of works in the collection
  class CollectionComponent < ApplicationComponent
    MAX_DEPOSITS_TO_SHOW = 4

    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    delegate :current_user, :user_with_groups, to: :helpers

    def visible_deposits
      # This component only displays MAX_DEPOSITS_TO_SHOW works but we query for
      # one more as a way to flag to the user that they should click through to
      # the collection works page to see more. We could query for the four
      # displayable works and add another query to get the overall count, but
      # that would double the number of queries run for each instance of this
      # component.
      scope = work_policy.apply_scope collection.works, type: :relation
      scope.order('works.updated_at desc').limit(MAX_DEPOSITS_TO_SHOW + 1)
    end

    def reviewer?
      policy.review?
    end

    private

    def work_policy
      WorkPolicy.new(user: current_user, user_with_groups: user_with_groups)
    end

    def policy
      CollectionPolicy.new(collection, user: current_user, user_with_groups: user_with_groups)
    end
  end
end
