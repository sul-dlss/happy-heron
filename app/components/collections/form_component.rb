# typed: true
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

    def draft_collections_path(collection)
      collections_path(collection)
    end
  end
end
