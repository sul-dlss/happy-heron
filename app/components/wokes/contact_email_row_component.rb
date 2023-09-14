# frozen_string_literal: true

module Wokes
  # Renders a row for an affiliation form.
  class ContactEmailRowComponent < ApplicationComponent
    def initialize(form:, controller:)
      @form = form
      @controller = controller
    end

    attr_reader :form, :controller

    def error?
      form.object.errors.where(:email).present?
    end
  end
end
