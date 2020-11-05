# typed: strict
# frozen_string_literal: true

module Works
  # The component that renders the form for editing or creating a work.
  class WorkFormComponent < ApplicationComponent
    sig { returns(WorkForm) }
    attr_reader :work_form

    sig { params(work_form: WorkForm).void }
    def initialize(work_form:)
      @work_form = work_form
    end

    sig { returns(T.any(WorkForm, T::Array[T.any(Collection, WorkForm)])) }
    def url
      persisted? ? work_form : [model.collection, work_form]
    end

    sig { returns(String) }
    def page_title
      persisted? ? model.title : 'Deposit your content'
    end

    delegate :model, to: :work_form

    delegate :persisted?, to: :model
  end
end
