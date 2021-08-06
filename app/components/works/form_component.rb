# frozen_string_literal: true

module Works
  # The component that renders the form for editing or creating a work.
  class FormComponent < ApplicationComponent
    attr_reader :work_form

    def initialize(work_form:)
      @work_form = work_form
    end

    def url
      persisted? ? work_form : [work.collection, work_form]
    end

    alias collection_draft_works_path collection_works_path

    def page_title
      work_version.title.presence || 'Deposit your content'
    end

    delegate :persisted?, to: :work_form
    delegate :purl, to: :work

    def work
      work_form.model.fetch(:work)
    end

    def work_version
      work_form.model.fetch(:work_version)
    end
  end
end
