# frozen_string_literal: true

module Works
  # Renders the details about the work (show page)
  class DetailComponent < ApplicationComponent
    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    delegate :purl, :collection, :events, :doi, :assign_doi, :druid, to: :work

    delegate :doi_option, to: :collection, prefix: true

    delegate :abstract, :attached_files, :authors, :citation, :contact_emails, :contributors,
             :created_edtf, :custom_rights, :first_draft?, :published_edtf, :rejected?, :related_links,
             :related_works, :version_description, :work, :work_type, to: :work_version

    def version
      return '1 - initial version' if first_draft?

      "#{version_number} - #{version_description}"
    end

    def doi_setting
      return 'DOI assigned (see above)' if doi

      case collection_doi_option
      when 'depositor-selects'
        assign_doi ? 'DOI not assigned' : 'Opted out of receiving a DOI'
      when 'yes'
        'DOI not assigned'
      else # 'no'
        'DOI will not be assigned'
      end
    end

    def depositor
      "#{work.depositor.sunetid} (#{work.depositor.name})"
    end

    def owner
      "#{work.owner.sunetid} (#{work.owner.name})"
    end

    def show_owner?
      work.owner != work.depositor
    end

    def collection_name
      collection.head.name
    end

    # Displays the created date as edtf

    def created
      format_edtf(created_edtf&.edtf)
    end

    # Displays the published date as edtf

    def published
      published_edtf&.edtf
    end

    def title
      WorkTitlePresenter.show(work_version)
    end

    def created_at
      render LocalTimeComponent.new(datetime: work_version.work.created_at)
    end

    def embargo_date
      work_version.embargo_date ? work_version.embargo_date.to_fs(:long) : 'Immediately'
    end

    def access
      work_version.access == 'stanford' ? 'Stanford Community' : 'Everyone'
    end

    def license
      License.label_for(work_version.license)
    end

    def subtypes
      Array(work_version.subtype).join(', ')
    end

    def work_type_label
      WorkType.find(work_type).html_label
    end

    def keywords
      work_version.keywords.map(&:label)
    end

    def display_approval?
      work_version.pending_approval?
    end

    def rejection_reason
      work.last_rejection_description
    end

    def previous_user_versions?
      return false unless Settings.user_versions_ui_enabled

      return true if work_version.user_version > 1

      false
    end

    def previous_user_versions
      (1..work_version.user_version - 1).to_a.reverse
    end

    def version_purl(version)
      purl + "/v/#{version}"
    end

    private

    def format_edtf(edtf)
      return if edtf.nil?

      # For example, "2020?/2021?" to "ca. 2020 - ca. 2021"
      edtf.sub(%r{/}, ' - ').gsub(/(\S+)\?/, 'ca. \1')
    end

    def version_number
      return work_version.user_version if Settings.user_versions_ui_enabled

      work_version.version
    end
  end
end
