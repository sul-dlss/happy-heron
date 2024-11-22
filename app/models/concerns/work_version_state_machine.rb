# frozen_string_literal: true

# Defines the states and transitions for a WorkVersion
module WorkVersionStateMachine
  extend ActiveSupport::Concern

  included do
    state_machine initial: :new do
      state :depositing do
        validate :correct_version
        validate :number_of_files
      end

      before_transition WorkObserver.method(:before_transition)

      after_transition WorkObserver.method(:after_transition)
      # NOTE: we do not want to fire this WorkObserver event twice, which will
      #       occur after when a new object is registered, first on object
      #       registration, and second after the PID is assigned... so only run
      #       this method the first time we enter the depositing state for a
      #       given version
      after_transition except_from: :depositing, to: :depositing, do: WorkObserver.method(:after_depositing)
      after_transition on: :reserve_purl, do: WorkObserver.method(:after_begin_reserve)
      after_transition on: :pid_assigned, do: WorkObserver.method(:after_druid_assigned)
      after_transition on: :reject, do: WorkObserver.method(:after_rejected)
      after_transition to: :pending_approval, do: WorkObserver.method(:after_submit_for_review)
      after_transition on: :deposit_complete, do: WorkObserver.method(:after_deposit_complete)
      after_transition on: :deposit_complete, do: CollectionObserver.method(:item_deposited)
      after_transition on: :decommission, do: WorkObserver.method(:after_decommission)

      # check to see if there any globus related actions needed when transitioning to any draft state
      after_transition to: %i[first_draft version_draft],
                       do: :check_globus_setup

      # Trigger the collection observer when starting a new draft,
      # except when the previous state was draft.
      after_transition except_from: :first_draft, to: :first_draft,
                       do: CollectionObserver.method(:first_draft_created)
      after_transition except_from: :version_draft, to: :version_draft,
                       do: CollectionObserver.method(:version_draft_created)

      # NOTE: there is no approval "event" because when a work is approved in review, it goes
      # directly to begin_deposit event, which will transition it to depositing
      event :begin_deposit do
        transition %i[first_draft version_draft pending_approval] => :depositing
      end

      event :deposit_complete do
        transition depositing: :deposited
      end

      event :pid_assigned do
        transition reserving_purl: :purl_reserved
        transition depositing: same
      end

      event :submit_for_review do
        transition %i[first_draft version_draft rejected] => :pending_approval
        transition pending_approval: same
      end

      event :reject do
        transition pending_approval: :rejected
      end

      event :reserve_purl do
        transition new: :reserving_purl
      end

      event :update_metadata do
        transition new: :first_draft
        transition %i[first_draft version_draft pending_approval rejected] => same
        transition purl_reserved: :first_draft
      end

      event :unzip do
        transition first_draft: :unzip_first_draft
        transition version_draft: :unzip_version_draft
      end

      event :unzip_and_submit_for_review do
        transition %i[first_draft version_draft rejected pending_approval] => :unzip_pending_approval
      end

      event :unzip_and_begin_deposit do
        transition %i[first_draft version_draft pending_approval] => :unzip_depositing
      end

      event :unzip_complete do
        transition unzip_first_draft: :first_draft
        transition unzip_version_draft: :version_draft
        transition unzip_pending_approval: :pending_approval
        transition unzip_depositing: :depositing
      end

      event :fetch_globus do
        transition first_draft: :fetch_globus_first_draft
        transition version_draft: :fetch_globus_version_draft
      end

      event :fetch_globus_and_submit_for_review do
        transition %i[first_draft version_draft rejected pending_approval] => :fetch_globus_pending_approval
      end

      event :fetch_globus_and_begin_deposit do
        transition %i[first_draft version_draft pending_approval] => :fetch_globus_depositing
      end

      event :fetch_globus_complete do
        transition fetch_globus_first_draft: :first_draft
        transition fetch_globus_version_draft: :version_draft
        transition fetch_globus_pending_approval: :pending_approval
        transition fetch_globus_depositing: :depositing
      end

      event :no_review_workflow do
        transition %i[pending_approval rejected] => :version_draft
      end

      event :decommission do
        transition all => :decommissioned
      end
    end

    def check_globus_setup
      return unless globus? && globus_endpoint.blank?

      # if the user selected the globus upload option, run the globus setup job each time we save as draft
      #  to see if there is any work to be done for globus setup
      #  Note: all work happens in a job because it makes API calls to Globus which shouldn't block the HTTP cycle
      GlobusSetupJob.perform_later(self)
    end

    def correct_version
      # Skip this check since no SDR API in dev.
      return if Rails.env.development?

      return unless work.druid

      return if Repository.valid_version?(druid: work.druid, h2_version: version)

      errors.add(:version, 'must be one greater than or equal to the version in SDR')
    end

    # prevent them from depositing an object with more than the allowed number of files
    # which could cause problems with the deposit process in accessioning
    def number_of_files
      return unless work.head

      return if work.head.attached_files.length < Settings.max_files_in_object

      errors.add(:base, "You cannot add more than #{Settings.max_files_in_object} files to an object.")
    end
  end
end
