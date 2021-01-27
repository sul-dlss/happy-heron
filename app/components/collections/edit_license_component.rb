# typed: strict
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
  end
end
