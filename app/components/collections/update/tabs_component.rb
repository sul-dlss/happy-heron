# frozen_string_literal: true

module Collections
  module Update
    # Renders the tabs for the collection edit page
    class TabsComponent < ApplicationComponent
      def initialize(collection:)
        @collection = collection
      end

      attr_reader :collection

      def collection_details_link
        classes = "nav-link"
        classes += " active" if current_page?(edit_collection_version_path(collection.head))
        link_to "Collection details", edit_collection_version_path(collection.head), class: classes, role: "tab"
      end

      def collection_settings_link
        classes = "nav-link"
        classes += " active" if current_page?(edit_collection_path(collection))
        link_to "Collection settings", edit_collection_path(collection), class: classes, role: "tab"
      end

      def deposits_link
        classes = "nav-link"
        classes += " active" if current_page?(collection_works_path(collection))
        link_to "Deposits", collection_works_path(collection), class: classes, role: "tab"
      end
    end
  end
end
