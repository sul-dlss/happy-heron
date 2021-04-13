# typed: true
# frozen_string_literal: true

module FirstDraftCollections
  module Create
    # The details (CollectionVersion) portion of the form for collections
    class DetailsComponent < ApplicationComponent
      def initialize(form:)
        @form = form
      end

      attr_reader :form
    end
  end
end
