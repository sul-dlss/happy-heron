# typed: false
# frozen_string_literal: true

module Dashboard
  # Display some information about a work that is in progress
  class InProgressRowComponent < ApplicationComponent
    with_collection_parameter :work

    def initialize(work:)
      @work = work
    end

    attr_reader :work

    def collection_name
      Dashboard::CollectionHeaderComponent.new(collection: work.collection).name
    end

    def edit_work_link
      link_to Works::DetailComponent.new(work: work).title, edit_work_path(work)
    end
  end
end
