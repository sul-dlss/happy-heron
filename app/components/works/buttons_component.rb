# typed: true
# frozen_string_literal: true

module Works
  # Displays the button for saving a draft or depositing for a work
  class ButtonsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    sig { returns(T.nilable(String)) }
    def submit_button_label
      work_in_reviewed_coll? ? 'Submit for approval' : 'Deposit'
    end

    private

    delegate :object, to: :form
    delegate :first_draft?, :version_draft?, :title, to: :work_version
    delegate :collection, to: :model

    def work_version
      object.model.fetch(:work_version)
    end

    def model
      object.model.fetch(:work)
    end

    sig { returns(T.nilable(T::Boolean)) }
    def work_in_reviewed_coll?
      collection.review_enabled?
    end
  end
end
