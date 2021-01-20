# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the widget that allows a user to cancel an edit in progress.
  class CancelComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection
  end
end
