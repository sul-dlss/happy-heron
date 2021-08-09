# frozen_string_literal: true

module Collections
  module Update
    # The component that renders the form for editing a collection.
    class SettingsFormComponent < ApplicationComponent
      attr_reader :collection_form

      delegate :model, to: :collection_form

      def initialize(collection_form:)
        @collection_form = collection_form
      end
    end
  end
end
