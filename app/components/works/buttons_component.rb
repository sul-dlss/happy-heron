# typed: false
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

    sig { returns(T.nilable(String)) }
    def delete_button
      return unless persisted?

      helpers.turbo_frame_tag dom_id(model, :delete), src: delete_button_work_path(model, style: :button)
    end

    sig { returns(T.nilable(String)) }
    def cancel_button
      render Works::CancelComponent.new(work: model)
    end

    private

    delegate :object, to: :form
    delegate :persisted?, to: :model

    def model
      object.model.fetch(:work)
    end

    sig { returns(T.nilable(T::Boolean)) }
    def work_in_reviewed_coll?
      model.collection.review_enabled?
    end
  end
end
