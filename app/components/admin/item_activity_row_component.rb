# frozen_string_literal: true

module Admin
  # Renders a list of all item events
  class ItemActivityRowComponent < ApplicationComponent
    with_collection_parameter :item

    def initialize(item:)
      @item = item
    end

    attr_reader :item

    def item_title
      WorkTitlePresenter.show(item.head)
    end

    delegate :collection, to: :item

    def collection_title
      CollectionTitlePresenter.show(collection.head)
    end
  end
end
