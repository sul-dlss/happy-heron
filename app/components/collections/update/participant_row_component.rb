# frozen_string_literal: true

module Collections
  module Update
    # Draws a participant in the collection
    class ParticipantRowComponent < ApplicationComponent
      def initialize(form:)
        @form = form
      end

      attr_reader :form

      delegate :sunetid, :name, to: :model_instance

      def model_instance
        form.object
      end
    end
  end
end
