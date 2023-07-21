# frozen_string_literal: true

module Wokes
  # Renders a row for an author form.
  class AuthorRowComponent < ApplicationComponent
    def initialize(form:, controller:)
      @form = form
      @controller = controller
    end

    attr_reader :form, :controller
  end
end
