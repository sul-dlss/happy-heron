# typed: false
# frozen_string_literal: true

module Collections
  # The component that renders the form for editing or creating a collection.
  class FormComponent < ApplicationComponent
    attr_reader :collection_form

    delegate :release_duration, to: :collection_form

    sig { params(collection_form: DraftCollectionForm).void }
    def initialize(collection_form:)
      @collection_form = collection_form
    end

    def embargo_release_duration_options
      DraftCollectionForm::EMBARGO_RELEASE_DURATION_OPTIONS
    end

    alias draft_collection_path collections_path
    alias create_collections_path collections_path
    alias create_collection_path collection_path
  end
end
