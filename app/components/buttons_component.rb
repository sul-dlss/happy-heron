# typed: true
# frozen_string_literal: true

# Displays the button for saving a draft or depositing
class ButtonsComponent < ApplicationComponent
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  def submit_button_label
    work_in_reviewed_coll? ? 'Submit for approval' : 'Deposit'
  end

  private

  delegate :object, to: :form

  sig { returns(T.nilable(Work)) }
  def maybe_work
    object.model if object.model.is_a?(Work)
  end

  sig { returns(T.nilable(T::Boolean)) }
  def work_in_reviewed_coll?
    maybe_work&.collection&.review_enabled?
  end
end
