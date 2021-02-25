# typed: false
# frozen_string_literal: true

module Collections
  module Show
    # Renders the tabs for the collection show page
    class TabsComponent < ApplicationComponent
      sig { params(collection: Collection).void }
      def initialize(collection:)
        @collection = collection
      end

      sig { returns(Collection) }
      attr_reader :collection

      sig { returns(String) }
      def collection_details_link
        classes = 'nav-link'
        classes += ' active' if current_page?(collection_version_path(collection.head))
        link_to 'Collection details', collection_version_path(collection.head), class: classes, role: 'tab'
      end

      sig { returns(String) }
      def collection_settings_link
        classes = 'nav-link'
        classes += ' active' if current_page?(collection_path(collection))
        link_to 'Collection settings', collection_path(collection), class: classes, role: 'tab'
      end

      sig { returns(String) }
      def deposits_link
        classes = 'nav-link'
        classes += ' active' if current_page?(collection_works_path(collection))
        link_to 'Deposits', collection_works_path(collection), class: classes, role: 'tab'
      end
    end
  end
end
