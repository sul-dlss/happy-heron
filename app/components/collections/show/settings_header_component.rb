# typed: false
# frozen_string_literal: true

module Collections
  module Show
    # Renders the header for the collection show page (title and create new link)
    class SettingsHeaderComponent < ApplicationComponent
      sig { params(collection_version: CollectionVersion).void }
      def initialize(collection_version:)
        @collection_version = collection_version
      end

      sig { returns(CollectionVersion) }
      attr_reader :collection_version

      delegate :depositing?, :updatable?, :collection, to: :collection_version

      sig { returns(String) }
      def name
        collection_version.name.presence || 'No Title'
      end

      sig { returns(String) }
      def spinner
        tag.span class: 'fas fa-spinner fa-pulse'
      end

      def can_create_work?
        collection_version.accessioned?
      end

      def edit_button
        return unless updatable?

        link_to 'Edit or Deposit', edit_collection_path(collection),
                class: 'btn btn-outline-primary float-end me-2'
      end

      def edit_link
        render Collections::EditLinkComponent.new(collection_version: collection_version,
                                                  anchor: '',
                                                  label: "Edit #{name}")
      end
    end
  end
end
