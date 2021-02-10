# typed: false
# frozen_string_literal: true

module Works
  # Renders the details about the work (show page)
  class DetailComponent < ApplicationComponent
    sig { params(work: Work).void }
    def initialize(work:)
      @work = work
    end

    sig { returns(Work) }
    attr_reader :work

    delegate :purl, :collection, :depositor, :events, to: :work

    delegate :version, :work_type, :contact_emails, :abstract, :citation,
             :attached_files, :related_works, :related_links,
             :created_edtf, :published_edtf, :rejected?, to: :work_version

    sig { returns(WorkVersion) }
    def work_version
      work.head
    end

    sig { returns(T::Array[AbstractContributor]) }
    def contributors
      work_version.authors + work_version.contributors
    end

    # Displays the created date as edtf
    sig { returns(T.nilable(String)) }
    def created
      created_edtf&.edtf
    end

    # Displays the published date as edtf
    sig { returns(T.nilable(String)) }
    def published
      published_edtf&.edtf
    end

    sig { returns(String) }
    def title
      work_version.title.presence || 'No title'
    end

    sig { returns(String) }
    def created_at
      work_version.created_at.to_formatted_s(:long)
    end

    sig { returns(String) }
    def updated_at
      work_version.updated_at.to_formatted_s(:long)
    end

    sig { returns(String) }
    def embargo_date
      work_version.embargo_date ? T.must(work_version.embargo_date).to_formatted_s(:long) : 'Immediately'
    end

    sig { returns(String) }
    def access
      work_version.access == 'stanford' ? 'Stanford Community' : 'Everyone'
    end

    sig { returns(String) }
    def license
      License::ID_LABEL_HASH[work_version.license]
    end

    sig { returns(String) }
    def subtypes
      Array(work_version.subtype).join(', ')
    end

    sig { returns(String) }
    def keywords
      work_version.keywords.map(&:label).join(', ')
    end

    sig { returns(T::Boolean) }
    def display_approval?
      work_version.pending_approval?
    end

    sig { returns(T.nilable(String)) }
    def rejection_reason
      work_version.last_rejection_description
    end
  end
end
