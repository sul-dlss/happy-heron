# frozen_string_literal: true

module Admin
  # Renders a list of all collection events
  class CollectionActivityRowComponent < ApplicationComponent
    with_collection_parameter :event

    def initialize(event:)
      @event = event
    end

    attr_reader :event

    def collection
      event.eventable
    end

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
