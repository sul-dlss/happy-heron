# typed: true
# frozen_string_literal: true

module Works
  # Draws a popup for selecting work type and subtype
  class WorkTypeModalComponent < ApplicationComponent
    def initialize(collection: nil)
      @collection = collection
    end

    def types
      WorkType.all
    end

    def collection_path
      return '/collections/1/work/new' if @collection.nil?

      new_collection_work_path(@collection)
    end
  end
end
