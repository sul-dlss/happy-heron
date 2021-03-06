# typed: true
# frozen_string_literal: true

module Collections
  # Renders the terms of use section of the collection (show page)
  class TermsOfUseComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :default_license, :required_license, :user_can_set_license?, to: :collection

    def collection_version
      collection.head
    end
  end
end
