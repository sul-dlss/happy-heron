# frozen_string_literal: true

module Collections
  module Update
    # The form for editing a CollectionVersion
    class DetailsFormComponent < ApplicationComponent
      attr_reader :collection_form

      delegate :model, to: :collection_form
      delegate :version_draft?, :first_draft?, :name, :collection, :version_description, to: :model

      def initialize(collection_form:)
        @collection_form = collection_form
      end
    end
  end
end
