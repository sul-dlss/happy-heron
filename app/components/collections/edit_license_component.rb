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
      # Can be a DraftCollectionForm or a CollectionSettingsForm
      form.object
    end

    def collection
      # If a DraftCollectionForm, the model is a Hash
      return form.object.model.fetch(:collection) if form.object.model.is_a?(Hash)

      # If a CollectionSettingsForm, the model is a Collection
      form.object.model
    end

    def custom_rights_statement_source_option
      collection.custom_rights_statement_source_option
    end

    def custom_rights_instructions_source_option
      collection.custom_rights_instructions_source_option
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
