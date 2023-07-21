# frozen_string_literal: true

module Wokes
  # A widget for managing the collection of contributors to the work.
  class AuthorsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form
  end
end
