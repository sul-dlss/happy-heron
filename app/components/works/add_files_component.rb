# typed: true
# frozen_string_literal: true

module Works
  class AddFilesComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
