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
    return unless persisted?

    path = if work_form?
             delete_button_work_path(model, style: :button)
           else
             delete_button_collection_path(model, style: :button)
           end

    helpers.turbo_frame_tag dom_id(model, :delete), src: path
  end

  sig { returns(T.nilable(String)) }
  def cancel_button
    if work_form?
      render Works::CancelComponent.new(work: model)
    else
      render Collections::CancelComponent.new(collection: model)
    end
  end

  private

  delegate :object, to: :form
  delegate :persisted?, to: :model

  def work_form?
    model_type == 'Hash'
  end

  def model
    work_form? ? work : object.model
  end

  def work
    object.model.fetch(:work)
  end

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
