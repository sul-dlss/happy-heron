# frozen_string_literal: true

module Works
  # Displays the button for saving a draft or depositing for a work
  class ButtonsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def submit_button_label
      work_in_reviewed_coll? ? 'Submit for approval' : 'Deposit'
    end

    private

    delegate :object, to: :form
    delegate :title, to: :work_version
    delegate :collection, to: :model

    def work_version
      object.model.fetch(:work_version)
    end

    def model
      object.model.fetch(:work)
    end

    def work_in_reviewed_coll?
      collection.review_enabled?
    end

    def show_version_draft_cancel?
      work_version.version_draft? && work_version.persisted?
    end

    def show_first_draft_cancel?
      work_version.deleteable?
    end

    def cancel_link_location
      if model.persisted?
        work_path(model)
      else
        collection_works_path(collection)
      end
    end

    def draft_button_actions
      if Settings.user_versions_ui_enabled
        'unsaved-changes#allowFormSubmission new-user-version#validateUserVersionSelection'
      else
        'unsaved-changes#allowFormSubmission'
      end
    end
  end
end
