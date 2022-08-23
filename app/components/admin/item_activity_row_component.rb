# frozen_string_literal: true

module Admin
  # Renders a list of all item events
  class ItemActivityRowComponent < ApplicationComponent
    with_collection_parameter :event

    def initialize(event:)
      @event = event
    end

    attr_reader :event

    def item
      event.eventable
    end

    def item_title
      item.head.title
    end

    delegate :collection, to: :item

    def collection_title
      collection.head.name
    end

    def action
      I18n.t(event.event_type, scope: 'event.type')
    end

    def event_date
      event.created_at
    end
  end
end
