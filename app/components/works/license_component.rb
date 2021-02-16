# typed: true
# frozen_string_literal: true

module Works
  # Renders a widget for selecting a license to apply to the work
  class LicenseComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def reform
      form.object
    end

    def collection
      reform.model.fetch(:work).collection
    end

    def license
      reform.model.fetch(:work_version).license || collection.default_license
    end

    delegate :user_can_set_license?, to: :collection

    def license_from_collection
      License.label_for(collection.required_license)
    end
  end
end
