# typed: false
# frozen_string_literal: true

module Collections
  # Renders the release section of the collection (show page)
  class ReleaseComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :release_option, :access, to: :collection
  end
end
