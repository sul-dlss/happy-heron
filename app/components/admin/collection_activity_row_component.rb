# frozen_string_literal: true

module Admin
  # Renders a list of all collection events
  class CollectionActivityRowComponent < ApplicationComponent
    with_collection_parameter :collection

    def initialize(collection:)
      @collection = collection
    end

    attr_reader :collection

    def collection_title
      CollectionTitlePresenter.show(collection.head)
    end
  end
end
