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
    delegate :title, to: :work_version
    delegate :sunetid, to: :owner

    def work_version
      work.head
    end

    def collection_title
      collection.head.name
    end
  end
end
