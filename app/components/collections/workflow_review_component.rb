# frozen_string_literal: true

module Collections
  # Renders the workflow review section of the collection (show page)
  class WorkflowReviewComponent < ApplicationComponent
    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    def review_workflow_status
      collection.review_enabled? ? 'On' : 'Off'
    end

    def reviewers
      collection.reviewed_by.map(&:sunetid).join(', ')
    end
  end
end
