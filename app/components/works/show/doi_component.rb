# frozen_string_literal: true

module Works
  module Show
    # Displays the DOI (or status of the DOI) on the work's show page.
    class DoiComponent < ApplicationComponent
      def initialize(work_version:)
        @work_version = work_version
      end

      attr_reader :work_version

      delegate :collection, :doi, :assign_doi, to: :work
      delegate :doi_option, to: :collection, prefix: true
      delegate :first_draft?, :work, to: :work_version

      # Nothing is returned if collection_doi_option is 'no'
      def render?
        collection_doi_option != 'no'
      end

      def call
        # If there is a DOI, return a link to it.
        return doi_link if doi
        return doi_later if collection_doi_option == 'yes'

        assign_doi ? doi_later : doi_opt_out
      end

      private

      def doi_later
        return tag.em 'DOI will become available once the work has been deposited.' if first_draft?

        # This is a version draft, the collection must have been changed to "yes"
        # after this item was deposited.
        'DOI will become available once a new version is deposited.'
      end

      def doi_opt_out
        'A DOI has not been assigned to this item. You may edit this item and select ' \
          '"Yes" for the DOI option if you would like to receive a DOI.'
      end

      def doi_link
        link = "https://doi.org/#{doi}"
        link_to link, link
      end
    end
  end
end
