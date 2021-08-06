# frozen_string_literal: true

module Collections
  module Update
    # Draws the widget for adding depositors to the collection
    class DepositorsComponent < ApplicationComponent
      def initialize(form:)
        @form = form
      end

      attr_reader :form
    end
  end
end
