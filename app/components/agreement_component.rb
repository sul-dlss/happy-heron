# typed: true
# frozen_string_literal: true

class AgreementComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
  end

  attr_reader :form
end
