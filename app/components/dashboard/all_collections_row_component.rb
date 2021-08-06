# frozen_string_literal: true

module Dashboard
  # Renders a list of all collections
  class AllCollectionsRowComponent < ApplicationComponent
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

    def state_count(state)
      return 0 unless counts.key? state

      counts.fetch(state)
    end

    def total
      return '0' if total_count.zero?

      link_to total_count, collection_works_path(collection)
    end

    private

    def total_count
      counts.fetch('total', 0)
    end
  end
end
