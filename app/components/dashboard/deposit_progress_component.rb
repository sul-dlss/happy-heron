# typed: strict
# frozen_string_literal: true

module Dashboard
  # displays the progress of this item on the dashboard
  class DepositProgressComponent < ApplicationComponent
    sig { params(work_version: WorkVersion).void }
    def initialize(work_version:)
      @form = T.let(WorkForm.new(work_version: work_version, work: work_version.work), WorkForm)
      @form.valid? # This triggers the form to run validations, so we can then query "valid_for?"
    end

    sig { returns(WorkForm) }
    attr_reader :form

    sig { returns(T::Boolean) }
    def has_file?
      valid_for?(:attached_files)
    end

    sig { returns(T::Boolean) }
    def has_title?
      valid_for?(:title, :contact_emails)
    end

    sig { returns(T::Boolean) }
    def has_author?
      valid_for?(:authors)
    end

    sig { returns(T::Boolean) }
    def has_description?
      valid_for?(:abstract, :keywords, :subtype)
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
      valid_for?(:agree_to_terms)
    end

    private

    sig { params(args: Symbol).returns(T::Boolean) }
    def valid_for?(*args)
      args.all? { |arg| form.errors.where(arg).empty? }
    end
  end
end
