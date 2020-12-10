# typed: true
# frozen_string_literal: true

module Dashboard
  # Renders a header for a summary table
  class CollectionHeaderComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    delegate :allowed_to?, to: :helpers
    delegate :depositing?, to: :collection

    sig { returns(String) }
    def name
      collection.name.presence || 'No Title'
    end

    sig { returns(String) }
    def spinner
      tag.span class: 'fas fa-spinner fa-pulse'
    end
  end
end
