# typed: true
# frozen_string_literal: true

class DatesComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
  end

  attr_reader :form
end
