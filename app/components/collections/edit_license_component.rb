# typed: false
# frozen_string_literal: true

module Collections
  # The component that renders the form for editing or creating a collection.
  class EditLicenseComponent < ApplicationComponent
    sig { params(form: ActionView::Helpers::FormBuilder).void }
    def initialize(form:)
      @form = form
    end

    sig { returns(ActionView::Helpers::FormBuilder) }
    attr_reader :form

    delegate :default_license, :required_license, to: :collection_form

    sig { returns(DraftCollectionForm) }
    def collection_form
      form.object
    end

    sig { returns(T::Boolean) }
    def error?
      errors.present?
    end

    def errors
      collection_form.errors.where(:license)
    end

    sig { returns(String) }
    def error_message
      safe_join(errors.map(&:message), tag.br)
    end
  end
end
