# typed: true
# frozen_string_literal: true

# Displays the button for saving a draft or depositing
class ButtonsComponent < ApplicationComponent
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  def depositable?
    helpers.allowed_to?(:deposit?, form.object.model)
  end
end
