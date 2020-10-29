# typed: true
# frozen_string_literal: true

module Works
  # The component that renders the form for editing or creating a work.
  class WorkFormComponent < ApplicationComponent
    attr_reader :work_form

    sig { params(work_form: WorkForm).void }
    def initialize(work_form:)
      @work_form = work_form
    end
  end
end
