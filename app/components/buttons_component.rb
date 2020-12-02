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

  def work_in_reviewed_coll?
    return false if form.object.instance_of?(CollectionForm)

    form.object.model.collection.review_enabled?
  end
end
