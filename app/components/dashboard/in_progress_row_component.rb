# typed: false
# frozen_string_literal: true

module Dashboard
  # Display some information about a work that is in progress
  class InProgressRowComponent < ApplicationComponent
    with_collection_parameter :work_version

    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    delegate :work, to: :work_version

    def collection_name
      Dashboard::CollectionHeaderComponent.new(collection: work.collection).name
    end

    def edit_work_link
      link_to edit_work_path(work), aria: { label: "Edit #{title}" } do
        tag.span class: 'fas fa-pencil-alt'
      end
    end

    def title
      @title ||= Works::DetailComponent.new(work_version: work_version).title
    end

    def work_link
      link_to truncate(title, length: 100, separator: ' '), edit_work_path(work), title: title
    end

    def show_collection_link
      truncated_collection_name = truncate(collection_name, length: 100, separator: ' ')
      link_to truncated_collection_name, work.collection, title: collection_name
    end
  end
end
