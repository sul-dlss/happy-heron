# frozen_string_literal: true

module Collections
  # The component that renders the form for editing or creating a collection.
  class EditTermsOfUseComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
