# frozen_string_literal: true

module Dashboard
  # Display some information about a work that is in progress
  class InProgressCollectionRowComponent < ApplicationComponent
    with_collection_parameter :collection_version

    def initialize(collection_version:)
      @collection_version = collection_version
    end

    attr_reader :collection_version

    delegate :collection, to: :collection_version

    def collection_name
      Dashboard::CollectionHeaderComponent.new(collection_version: collection_version).name
    end

    def show_collection_link
      truncated_collection_name = truncate(collection_name, length: 100, separator: ' ')
      link_to truncated_collection_name, collection, title: collection_name
    end
  end
end
