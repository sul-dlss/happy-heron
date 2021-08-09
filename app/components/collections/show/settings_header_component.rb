# frozen_string_literal: true

module Collections
  module Show
    # Renders the header for the collection show page (title and create new link).
    # This component ought to have a sibling component of Works::WorkTypeModalComponent
    # and it ought to be within a data-controller="work-type" attribute because
    # this component contains a button that acts on that controller
    class SettingsHeaderComponent < ApplicationComponent
      def initialize(collection_version:)
        @collection_version = collection_version
      end

      attr_reader :collection_version

      delegate :depositing?, :draft?, :collection, to: :collection_version

      def name
        collection_version.name.presence || 'No Title'
      end

      def spinner
        tag.span class: 'fas fa-spinner fa-pulse'
      end

      def can_create_work?
        collection_version.accessioned?
      end

      def edit_button
        return unless draft?

        link_to 'Edit or Deposit', edit_collection_path(collection),
                class: 'btn btn-outline-primary me-2'
      end
    end
  end
end
