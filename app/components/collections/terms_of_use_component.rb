# typed: false
# frozen_string_literal: true

module Collections
  # Renders the details about the work (show page)
  class TermsOfUseComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :default_license, to: :collection
  end
end
