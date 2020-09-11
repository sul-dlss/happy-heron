# frozen_string_literal: true

class EmbargoComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
  end

  attr_reader :form
end
