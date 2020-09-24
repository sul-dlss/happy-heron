# typed: true
# frozen_string_literal: true

class WorkFormComponent < ApplicationComponent
  attr_reader :work

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end
end
