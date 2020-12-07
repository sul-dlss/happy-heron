# typed: strict
# frozen_string_literal: true

module Collections
  # Renders the header for the collection show page (title and create new link)
  class LinksComponent < ApplicationComponent
    sig { params(collection: Collection).void }
    def initialize(collection:)
      @collection = collection
    end

    sig { returns(Collection) }
    attr_reader :collection

    delegate :related_links, to: :collection
  end
end
