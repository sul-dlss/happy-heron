# typed: true
# frozen_string_literal: true

module Collections
  # Renders a link to the collection edit page
  class EditLinkComponent < ApplicationComponent
    sig { params(collection_version: CollectionVersion, anchor: String, label: String).void }
    def initialize(collection_version:, anchor:, label:)
      @collection_version = collection_version
      @anchor = anchor
      @label = label
    end

    sig { returns(T::Boolean) }
    def render?
      collection_version.can_update_metadata?
    end

    attr_reader :collection_version, :anchor, :label
    delegate :collection, to: :collection_version
  end
end
