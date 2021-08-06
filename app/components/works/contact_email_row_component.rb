# frozen_string_literal: true

module Works
  # Renders a widget for describing a related link.
  class ContactEmailRowComponent < ApplicationComponent
    def initialize(form:, key:)
      @form = form
      @key = key
    end

    attr_reader :form, :key

    def tooltip
      render PopoverComponent.new key: key
    end

    def not_first_email?
      form.index != 0
    end

    def bootstrap_classes
      return 'col-sm-10 col-xl-8' if form.object_name.start_with?('collection')

      # Should be a work
      'col-sm-9'
    end

    def errors
      form.object.errors.where(:email)
    end

    def error?
      errors.present?
    end
  end
end
