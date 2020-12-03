# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the workflow review section of the collection (show page)
  class WorkflowReviewComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    sig { returns(String) }
    def review_workflow_status
      collection.review_enabled? ? 'On' : 'Off'
    end

    sig { returns(T.nilable(String)) }
    def reviewers
      collection.reviewers.pluck(:email).join(', ')
    end
  end
end
