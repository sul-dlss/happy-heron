# typed: true
# frozen_string_literal: true

module FirstDraftCollections
  module Create
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
    end
  end
end
