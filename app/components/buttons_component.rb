# typed: true
# frozen_string_literal: true

class ButtonsComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
  end

  attr_reader :form
end
