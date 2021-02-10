# typed: strict
# frozen_string_literal: true

module Dashboard
  # displays the progress of this item on the dashboard
  class DepositProgressComponent < ApplicationComponent
    sig { params(work_version: WorkVersion).void }
    def initialize(work_version:)
      @work_version = work_version
    end

    sig { returns(WorkVersion) }
    attr_reader :work_version

    delegate :attached_files, :title, :contact_emails, :authors, :abstract, :keywords,
             :agree_to_terms, to: :work_version

    sig { returns(T::Boolean) }
    def has_file?
      attached_files.any?
    end

    sig { returns(T::Boolean) }
    def has_title?
      title.present? && contact_emails.any?
    end

    sig { returns(T::Boolean) }
    def has_author?
      authors.any?
    end

    sig { returns(T::Boolean) }
    def has_description?
      abstract.present? && keywords.any?
    end

    sig { returns(TrueClass) }
    def has_release?
      true # The release section is always done as it defaults to a valid choice.
    end

    sig { returns(TrueClass) }
    def has_license?
      true # The license section is always done as it defaults to a valid choice.
    end

    sig { returns(T.nilable(T::Boolean)) }
    def has_terms?
      agree_to_terms
    end
  end
end
