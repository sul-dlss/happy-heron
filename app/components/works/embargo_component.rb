# typed: false
# frozen_string_literal: true

module Works
  # Renders a widget for defining an embargo on a work.
  class EmbargoComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def collection
      form.object.model.collection
    end

    delegate :user_can_set_availability?, to: :collection

    # The access level is specified by the collection
    def user_can_set_access?
      true # TODO: by https://github.com/sul-dlss/happy-heron/pull/884
    end

    def availability_from_collection
      return 'immediately upon deposit' if collection.release_option == 'immediate'

      "starting on #{collection.release_date.to_formatted_s(:long)}"
    end

    def access_from_collection
      'TBD' # TODO: by https://github.com/sul-dlss/happy-heron/pull/884
    end
  end
end
