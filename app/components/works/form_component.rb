# frozen_string_literal: true

module Works
  # The component that renders the form for editing or creating a work.
  class FormComponent < ApplicationComponent
    attr_reader :work_form

    def initialize(work_form:)
      @work_form = work_form
    end

    def url
      persisted? ? work_form : [work.collection, work_form]
    end

    alias collection_draft_works_path collection_works_path

    def page_title
      work_version.title.presence || 'Deposit your content'
    end

    delegate :persisted?, to: :work_form
    delegate :purl, to: :work
    delegate :druid, to: :work
    delegate :doi, to: :work
    delegate :will_assign_doi?, to: :work_form

    def work
      work_form.model.fetch(:work)
    end

    def work_version
      work_form.model.fetch(:work_version)
    end

    delegate :user_version, to: :work_version

    def user_versions_ui_enabled?
      Settings.user_versions_ui_enabled
    end

    def doi_field
      return "https://doi.org/#{doi}." if doi

      # create DOI URL or placeholder for works in collections that allow DOI assignment
      return unless will_assign_doi?

      return "https://doi.org/#{Doi.for(druid)}." if druid

      WorkVersion::DOI_TEXT
    end

    def data_controllers
      return 'auto-citation unsaved-changes deposit-button new-user-version attached-files' if user_versions_ui_enabled?

      'auto-citation unsaved-changes deposit-button'
    end
  end
end
