# frozen_string_literal: true

module Collections
  # The settings (Collection) portion of the form for collections
  class SettingsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def embargo_release_duration_options
      Collection::EMBARGO_RELEASE_DURATION_OPTIONS
    end

    delegate :release_duration, to: :collection_form

    def collection_form
      form.object
    end

    def release_option_errors?
      release_option_errors.present?
    end

    def release_option_errors
      collection_form.errors.where(:release_option)
    end

    def release_option_error_message
      safe_join(release_option_errors.map { |error| "Release option #{error.message}" }, tag.br)
    end
  end
end
