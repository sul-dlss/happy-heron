# typed: true
# frozen_string_literal: true

module Collections
  # The component that renders the form for editing or creating a collection.
  class FormComponent < ApplicationComponent
    attr_reader :collection_form

    sig { params(collection_form: CollectionForm).void }
    def initialize(collection_form:)
      @collection_form = collection_form
    end
  end
end
