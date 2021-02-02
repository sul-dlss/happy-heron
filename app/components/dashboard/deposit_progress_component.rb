# typed: strict
# frozen_string_literal: true

module Dashboard
  # displays the progress of this item on the dashboard
  class DepositProgressComponent < ApplicationComponent
    sig { params(work: Work).void }
    def initialize(work:)
      @work = work
    end

    sig { returns(Work) }
    attr_reader :work

    sig { returns(T::Boolean) }
    def has_file?
      work.attached_files.any?
    end

    sig { returns(T::Boolean) }
    def has_title?
      work.title.present?
    end

    sig { returns(T::Boolean) }
    def has_author?
      work.authors.any?
    end

    sig { returns(T::Boolean) }
    def has_description?
      work.abstract.present? && work.keywords.any?
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
      work.agree_to_terms
    end
  end
end
