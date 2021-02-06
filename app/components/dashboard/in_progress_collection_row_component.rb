# typed: false
# frozen_string_literal: true

module Dashboard
  # Display some information about a work that is in progress
  class InProgressCollectionRowComponent < ApplicationComponent
    with_collection_parameter :collection

    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    def collection_name
      Dashboard::CollectionHeaderComponent.new(collection: collection).name
    end

    def show_collection_link
      truncated_collection_name = truncate(collection_name, length: 100, separator: ' ')
      link_to truncated_collection_name, collection, title: collection_name
    end
  end
end
