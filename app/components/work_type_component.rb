# typed: true
class WorkTypeComponent < ViewComponent::Base
  def initialize(form:)
    @form = form
  end

  attr_reader :form

  def work
    form.object
  end

  delegate :work_type, to: :work
end
