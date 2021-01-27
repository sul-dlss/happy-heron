# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the terms of use section of the collection (show page)
  class TermsOfUseComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :default_license, :required_license, to: :collection
  end
end
