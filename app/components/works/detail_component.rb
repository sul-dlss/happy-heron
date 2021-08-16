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

    delegate :work_type, :contact_emails, :abstract, :citation, :first_draft?,
             :attached_files, :related_works, :related_links,
             :created_edtf, :published_edtf, :rejected?, :work, :description, to: :work_version

    def contributors
      work_version.authors + work_version.contributors
    end

    def version
      return '1 - initial version' if first_draft?

      "#{work_version.version} - #{description}"
    end

    def doi_value
      # If there is a DOI, return a link to it.
      return doi_link if doi

      case collection_doi_option
      when 'yes'
        doi_later
      when 'depositor-selects'
        if assign_doi
          doi_later
        else
          doi_opt_out
        end
      end
      # Nothing is returned if collection_doi_option is 'no'
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

    def doi_opt_out
      'A DOI has not been assigned to this item. You may edit this item and select ' \
        '"Yes" for the DOI option if you would like to receive a DOI.'
    end

    def doi_later
      return tag.em 'DOI will become available once the work has been deposited.' if first_draft?

      # This is a version draft, the collection must have been changed to "yes"
      # after this item was deposited.
      'DOI will become available once a new version is deposited.'
    end
  end
end
