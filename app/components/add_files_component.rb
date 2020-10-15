# typed: true
# frozen_string_literal: true

class AddFilesComponent < ApplicationComponent
  def initialize(form:)
    @form = form
  end

  attr_reader :form
end
