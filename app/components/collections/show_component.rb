# typed: false
# frozen_string_literal: true

module Collections
  # Base component class for the collection details show page (common methods used by call components on that page)
  class ShowComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    sig { params(anchor: String, label: String).returns(String) }
    def edit_link(anchor, label)
      link_to edit_collection_path(collection, anchor: anchor), aria: { label: label } do
        tag.span class: 'fas fa-pencil-alt edit'
      end
    end
  end
end
