# frozen_string_literal: true

module Wokes
  # Displays the button for saving a draft or depositing for a work
  class ButtonsComponent < ApplicationComponent
    def initialize(form:)
      @form = form
    end

    attr_reader :form

    def submit_button_label
      work_in_reviewed_coll? ? "Submit for approval" : "Deposit"
    end

    private

    def collection
      form.object.collection
    end

    def work_version
      form.object.work_version
    end

    def work
      form.object.work
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
      if work_version.persisted?
        work_path(work)
      else
        collection_works_path(collection)
      end
    end
  end
end
