# frozen_string_literal: true

module Collections
  module Update
    # Draws the widget for adding reviewers to the collection
    class ReviewersComponent < ApplicationComponent
      def initialize(form:)
        @form = form
      end

      attr_reader :form
    end
  end
end
