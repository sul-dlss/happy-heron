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

    delegate :purl, :collection, :version, :work_type,
             :contact_email, :abstract, :citation,
             :depositor, :attached_files,
             :related_works, :related_links, :events,
             to: :work

    sig { returns(T::Array[AbstractContributor]) }
    def contributors
      work.authors + work.contributors
    end

    # Displays the created date as edtf
    sig { returns(T.nilable(String)) }
    def created
      work.created_edtf&.edtf
    end

    # Displays the published date as edtf
    sig { returns(T.nilable(String)) }
    def published
      work.published_edtf&.edtf
    end

    sig { returns(String) }
    def title
      work.title.presence || 'No title'
    end

    sig { returns(String) }
    def created_at
      work.created_at.to_formatted_s(:long)
    end

    sig { returns(String) }
    def updated_at
      work.updated_at.to_formatted_s(:long)
    end

    sig { returns(String) }
    def embargo_date
      work.embargo_date ? T.must(work.embargo_date).to_formatted_s(:long) : 'Immediately'
    end

    sig { returns(String) }
    def access
      work.access == 'stanford' ? 'Stanford Community' : 'Everyone'
    end

    sig { returns(String) }
    def license
      License::ID_LABEL_HASH[work.license]
    end

    sig { returns(String) }
    def subtypes
      Array(work.subtype).join(', ')
    end

    sig { returns(String) }
    def keywords
      work.keywords.map(&:label).join(', ')
    end

    sig { returns(T::Boolean) }
    def display_approval?
      work.pending_approval?
    end

    sig { returns(T.nilable(String)) }
    def rejection_reason
      work.last_rejection_description
    end
  end
end
