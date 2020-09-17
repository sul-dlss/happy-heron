# frozen_string_literal: true

class AddFilesComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
  end

  attr_reader :form
end
