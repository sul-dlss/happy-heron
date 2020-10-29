# typed: true
# frozen_string_literal: true

module Works
  # The widget that uploads files to active storage and attaches them to the work.
  class AddFilesComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
