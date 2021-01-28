# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for selecting a license to apply to the work
  class LicenseComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    delegate :license, to: :reform

    def reform
      form.object
    end

    def collection
      reform.model.collection
    end

    delegate :user_can_set_license?, to: :collection

    def license_from_collection
      License.label_for(collection.required_license)
    end
  end
end
