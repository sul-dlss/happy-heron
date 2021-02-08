# typed: false
# frozen_string_literal: true

# Displays the button for saving a draft or depositing
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
    return unless object.model.persisted?

    path = if model_type == 'Work'
             delete_button_work_path(object.model, style: :button)
           else
             delete_button_collection_path(object.model, style: :button)
           end

    helpers.turbo_frame_tag dom_id(object.model, :delete), src: path
  end

  sig { returns(T.nilable(String)) }
  def cancel_button
    if model_type == 'Work'
      render Works::CancelComponent.new(work: object.model)
    else
      render Collections::CancelComponent.new(collection: object.model)
    end
  end

  private

  delegate :object, to: :form

  sig { returns(T.nilable(String)) }
  def model_type
    object.model.class.to_s
  end

  sig { returns(T.nilable(Work)) }
  def maybe_work
    object.model if object.model.is_a?(Work)
  end

  sig { returns(T.nilable(T::Boolean)) }
  def work_in_reviewed_coll?
    maybe_work&.collection&.review_enabled?
  end
end
