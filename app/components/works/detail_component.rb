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

    delegate :title, :purl, :collection, :version, :work_type,
             :contact_email,  :abstract, :citation,
             :published_edtf, :created_edtf,
             :depositor, :attached_files, :contributors,
             :related_works, :related_links,
             to: :work

    sig { returns(String) }
    def created_at
      work.created_at.to_formatted_s(:long)
    end

    sig { returns(String) }
    def updated_at
      work.updated_at.to_formatted_s(:long)
    end

    sig { params(anchor: String, label: String).returns(String) }
    def edit_link(anchor, label)
      link_to edit_work_path(work, anchor: anchor), aria: { label: label } do
        tag.span class: 'fas fa-pencil-alt edit'
      end
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
  end
end
