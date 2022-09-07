# frozen_string_literal: true

module Admin
  # Renders a table row containing a locked item
  class LockedItemRowComponent < ApplicationComponent
    with_collection_parameter :work

    def initialize(work:)
      @work = work
    end

    attr_reader :work

    delegate :collection, :druid_without_namespace, :owner, to: :work
    delegate :sunetid, to: :owner

    def work_version
      work.head
    end

    def title
      WorkTitlePresenter.show(work_version)
    end

    def collection_title
      CollectionTitlePresenter.show(collection.head)
    end
  end
end
