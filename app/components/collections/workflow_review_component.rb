# typed: true
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

    def collection_version
      collection.head
    end

    sig { returns(String) }
    def review_workflow_status
      collection.review_enabled? ? 'On' : 'Off'
    end

    sig { returns(T.nilable(String)) }
    def reviewers
      collection.reviewed_by.map(&:sunetid).join(', ')
    end
  end
end
