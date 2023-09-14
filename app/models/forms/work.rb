module Forms
  class Work < Base
    # Indicates that this is a deposit, and therefore should be fully validated.
    attr_accessor :_deposit
    attr_accessor :id
    attr_accessor :title
    attr_accessor :abstract
    attr_accessor :collection_id
    attr_accessor :work_type
    attr_accessor :license
    attr_accessor :depositor
    attr_accessor :owner
    attr_accessor :assign_doi

    # *_attributes is needed in order to use the
    # fields_for helper with a collection
    attr_accessor :authors_attributes
    attr_accessor :contributors_attributes
    attr_accessor :contact_emails_attributes

    delegate :purl, :druid, :doi, to: :work

    with_options if: :_deposit do
      validates :title, presence: true, allow_nil: false
      validates :abstract, presence: true, allow_nil: false
      validates :contact_emails, length: {minimum: 1, message: "Please add at least 1 contact email."}
    end

    # Required override of base class
    def main_model
      work_version
    end

    # Optional override of base class
    # The work is saved before the work version.
    def parent_models
      [work]
    end

    # Optional override of base class
    def associated_forms
      authors + contributors + contact_emails
    end

    def work
      @work ||= if id.present?
        ::Work.find(id)
      else
        ::Work.new(
          collection: collection,
          depositor: depositor,
          owner: owner,
          assign_doi: assign_doi
        )
      end
    end

    def work_version
      @work_version ||= begin
        work_version = if work.head.present?
          work.head
        else
          WorkVersion.new(work: work)
        end
        work.head = work_version
        work_version.title = title
        work_version.abstract = abstract
        work_version.work_type = work_type
        work_version.license = license
        work_version
      end
    end

    def collection
      @collection ||= Collection.find(collection_id)
    end

    def authors
      @authors ||= if authors_attributes.present?
        authors_attributes.filter_map do |_, author_params|
          # This filter out blank forms.
          Forms::Author.new(author_params.merge(work_version: work_version, _deposit: _deposit)) unless Forms::Author.reject_all_blank?(author_params)
        end
      elsif work_version.authors.present?
        work_version.authors.map do |author|
          Forms::Author.new_from_model(author)
        end
      else
        []
      end
    end

    # This adds a blank form when none are present.
    def authors_forms
      authors.present? ? authors : [Forms::Author.new]
    end

    def contributors
      @contributors ||= if contributors_attributes.present?
        contributors_attributes.filter_map do |_, contributor_params|
          # This filter out blank forms.
          Forms::Contributor.new(contributor_params.merge(work_version: work_version, _deposit: _deposit)) unless Forms::Contributor.reject_all_blank?(contributor_params)
        end
      elsif work_version.contributors.present?
        work_version.contributors.map do |contributor|
          Forms::Contributor.new_from_model(contributor)
        end
      else
        []
      end
    end

    # This adds a blank form when none are present.
    def contributors_forms
      contributors.present? ? contributors : [Forms::Contributor.new]
    end

    def contact_emails
      @contact_emails ||= if contact_emails_attributes.present?
        contact_emails_attributes.filter_map do |_, contact_email_params|
          # This filter out blank forms.
          Forms::ContactEmail.new(contact_email_params.merge(emailable: work_version)) unless Forms::ContactEmail.reject_all_blank?(contact_email_params)
        end
      elsif work_version.contact_emails.present?
        work_version.contact_emails.map do |contact_email|
          Forms::ContactEmail.new_from_model(contact_email)
        end
      else
        []
      end
    end

    # This adds a blank form when none are present.
    def contact_emails_forms
      contact_emails.present? ? contact_emails : [Forms::ContactEmail.new]
    end

    def self.new_from_model(work)
      new(collection_id: work.collection_id,
        id: work.id,
        title: work.head.title,
        abstract: work.head.abstract,
        assign_doi: work.assign_doi)
    end

    def will_assign_doi?
      (collection.doi_option == "depositor-selects" && assign_doi) || collection.doi_option == "yes"
    end
  end
end
