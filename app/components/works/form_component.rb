# typed: strict
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
      persisted? ? work_form : [model.collection, work_form]
    end

    sig { returns(String) }
    def page_title
      persisted? ? model.title : 'Deposit your content'
    end

    delegate :model, to: :work_form

    delegate :persisted?, :purl, to: :model
  end
end
