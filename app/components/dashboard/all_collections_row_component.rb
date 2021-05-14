# typed: true
# frozen_string_literal: true

module Dashboard
  # Renders a list of all collections
  class AllCollectionsRowComponent < ApplicationComponent
    sig { params(collection: Collection, counts: Hash).void }
    def initialize(collection:, counts:)
      @collection = collection
      @counts = counts
    end

    attr_reader :collection, :counts

    def draft_label
      case @collection.head&.state
      when 'first_draft'
        return '- Draft'
      when 'version_draft'
        return '- Version Draft'
      end

      nil
    end
  end
end
