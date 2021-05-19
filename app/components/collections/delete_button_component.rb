# typed: false
# frozen_string_literal: true

module Collections
  # Render the delete button for a collection
  class DeleteButtonComponent < ApplicationComponent
    CONFIRM_MESSAGE = 'Are you sure you want to delete this draft collection? It cannot be undone.'

    def initialize(collection_version:)
      @collection_version = collection_version
    end

    def render?
      allowed_to?(:destroy?, collection)
    end

    attr_reader :collection_version

    delegate :collection, to: :collection_version
    delegate :allowed_to?, to: :helpers

    def call
      link_to collection_path(collection), method: :delete, aria: { label: "Delete #{collection_version.name}" },
                                           data: { confirm: CONFIRM_MESSAGE } do
        tag.span class: 'far fa-trash-alt'
      end
    end
  end
end
