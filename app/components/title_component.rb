# typed: true
# frozen_string_literal: true

class TitleComponent < ApplicationComponent
  def initialize(form:)
    @form = form
  end

  attr_reader :form
end
