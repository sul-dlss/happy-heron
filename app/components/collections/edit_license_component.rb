# frozen_string_literal: true

module Collections
  # The component that renders the form for editing or creating a collection.
  class EditLicenseComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    delegate :default_license, :required_license, to: :collection_form

    def collection_form
      form.object
    end

    def error?
      errors.present?
    end

    def errors
      collection_form.errors.where(:license)
    end

    def error_message
      safe_join(errors.map(&:message), tag.br)
    end
  end
end
