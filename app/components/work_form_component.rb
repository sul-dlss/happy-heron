# frozen_string_literal: true

class WorkFormComponent < ViewComponent::Base
  attr_reader :work

  def initialize(work:)
    @work = work
  end
end
