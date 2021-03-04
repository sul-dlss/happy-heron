# typed: false
# frozen_string_literal: true

module Collections
  module Create
    # Displays the buttons for saving a draft or depositing for a collection
    class ButtonsComponent < ApplicationComponent
      def initialize(form:)
        @form = form
      end

      attr_reader :form

      sig { returns(String) }
      def cancel_button
        link_to 'Cancel', dashboard_path, class: 'btn btn-link'
      end

      delegate :object, to: :form
      delegate :persisted?, to: :object
      delegate :first_draft?, :name, to: :collection_version

      def model
        object.collection
      end

      def collection_version
        object.model.fetch(:collection_version)
      end
    end
  end
end
