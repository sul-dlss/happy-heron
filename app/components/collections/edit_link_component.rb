# typed: false
# frozen_string_literal: true

module Collections
  # Renders a link to the collection edit page
  class EditLinkComponent < ApplicationComponent
    sig { params(collection_version: CollectionVersion, label: String, anchor: String).void }
    def initialize(collection_version:, label:, anchor: '')
      @collection_version = collection_version
      @anchor = anchor
      @label = label
    end

    sig { returns(T::Boolean) }
    def render?
      allowed_to?(:update?, collection_version)
    end

    def call
      link_to edit_collection_path(collection, anchor: anchor), aria: { label: label } do
        tag.span class: 'fas fa-pencil-alt edit'
      end
    end

    attr_reader :collection_version, :anchor, :label

    delegate :collection, to: :collection_version
    delegate :allowed_to?, to: :helpers
  end
end
