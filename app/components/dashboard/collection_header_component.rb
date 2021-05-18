# typed: false
# frozen_string_literal: true

module Dashboard
  # Renders a header for a summary table
  class CollectionHeaderComponent < ApplicationComponent
    sig { params(collection_version: CollectionVersion).void }
    def initialize(collection_version:)
      @collection_version = collection_version
    end

    attr_reader :collection_version

    delegate :depositing?, :first_draft?, to: :collection_version
    delegate :collection, to: :collection_version
    delegate :allowed_to?, to: :helpers

    sig { returns(String) }
    def name
      collection_version.name.presence || 'No Title'
    end

    sig { returns(String) }
    def spinner
      tag.span class: 'fas fa-spinner fa-pulse'
    end

    # We aren't using Collection::EditLinkComponent here because it doesn't check
    # whether you are allowed to edit a collection.
    def edit_link
      return unless allowed_to?(:update?, collection_version)

      link_to edit_collection_path(collection), aria: { label: "Edit #{name}" } do
        tag.span class: 'fas fa-pencil-alt edit'
      end
    end
  end
end
