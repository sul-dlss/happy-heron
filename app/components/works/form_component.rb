# typed: false
# frozen_string_literal: true

module Works
  # The component that renders the form for editing or creating a work.
  class FormComponent < ApplicationComponent
    sig { returns(DraftWorkForm) }
    attr_reader :work_form

    sig { params(work_form: DraftWorkForm).void }
    def initialize(work_form:)
      @work_form = work_form
    end

    sig { returns(T.any(DraftWorkForm, T::Array[T.any(Collection, DraftWorkForm)])) }
    def url
      persisted? ? work_form : [work.collection, work_form]
    end

    alias collection_draft_works_path collection_works_path

    sig { returns(String) }
    def page_title
      persisted? ? work_version.title : 'Deposit your content'
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
