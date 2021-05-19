# typed: false
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
      return unless @collection.head&.state&.include? 'draft'

      case @collection.head&.state
      when 'first_draft'
        tag.span ' - Draft', class: 'draft-tag'
      when 'version_draft'
        tag.span ' - Version Draft', class: 'draft-tag'
      end
    end
  end
end
