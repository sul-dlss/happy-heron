# frozen_string_literal: true

module Works
  # Renders the details about the work (show page)
  class DetailComponent < ApplicationComponent
    def initialize(work_version:)
      @work_version = work_version
    end

    attr_reader :work_version

    delegate :purl, :collection, :events, :doi, :assign_doi, :druid, to: :work

    delegate :doi_option, to: :collection

    delegate :work_type, :contact_emails, :abstract, :citation,
             :attached_files, :related_works, :related_links,
             :created_edtf, :published_edtf, :rejected?, :work, :description, to: :work_version

    def contributors
      work_version.authors + work_version.contributors
    end

    def version
      return '1 - initial version' if work_version.version == 1

      "#{work_version.version} - #{description}"
    end

    def doi_value
      # If there is a DOI, return a link to it.
      return doi_link if doi

      # If not assigning a DOI, return nothing.
      return if doi_option == 'no'

      # If possibly assigning a DOI and the PURL has been assigned, return possible DOI.
      return doi_tbd if purl

      # If assigning a DOI and PURL has not been assigned, return message.
      return unless doi_option == 'yes' || (doi_option == 'depositor-selects' && assign_doi)

      tag.em 'DOI will become available once the work has been deposited.'
    end

    def doi_setting
      return 'DOI assigned (see above)' if doi

      case doi_option
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
      render LocalTimeComponent.new(datetime: work_version.created_at)
    end

    def updated_at
      render LocalTimeComponent.new(datetime: work_version.updated_at)
    end

    def embargo_date
      work_version.embargo_date ? work_version.embargo_date.to_formatted_s(:long) : 'Immediately'
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

    def keywords
      work_version.keywords.map(&:label)
    end

    def display_approval?
      work_version.pending_approval?
    end

    def rejection_reason
      work.last_rejection_description
    end

    private

    def format_edtf(edtf)
      return if edtf.nil?

      # For example, "2020?/2021?" to "ca. 2020 - ca. 2021"
      edtf.sub(%r{/}, ' - ').gsub(/(\S+)\?/, 'ca. \1')
    end

    def doi_link
      link = "https://doi.org/#{doi}"
      link_to link, link
    end

    def doi_tbd
      "The DOI for this item will be DOI:#{Settings.datacite.prefix}/#{druid.delete_prefix('druid:')} (if assigned)."
    end
  end
end
