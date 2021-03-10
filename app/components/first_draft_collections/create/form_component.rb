# typed: false
# frozen_string_literal: true

module FirstDraftCollections
  module Create
    # The component that renders the form for creating a collection.
    class FormComponent < ApplicationComponent
      attr_reader :collection_form

      sig { params(collection_form: DraftCollectionForm).void }
      def initialize(collection_form:)
        @collection_form = collection_form
      end

      alias collections_path first_draft_collections_path
      alias collection_path first_draft_collection_path
    end
  end
end
