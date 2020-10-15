# typed: true
# frozen_string_literal: true

class WorkTypeComponent < ApplicationComponent
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  def work
    form.object
  end

  delegate :work_type, to: :work
end
