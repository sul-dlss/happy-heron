# typed: true
# frozen_string_literal: true

module Collections
  # Renders a link to the collection edit page
  class EditLinkComponent < ApplicationComponent
    sig { params(collection: Collection, anchor: String, label: String).void }
    def initialize(collection:, anchor:, label:)
      @collection = collection
      @anchor = anchor
      @label = label
    end

    attr_reader :collection, :anchor, :label
  end
end
