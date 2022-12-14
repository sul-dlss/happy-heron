# frozen_string_literal: true

# Defines the states and transitions for a WorkVersion
module WorkVersionStateMachine
  extend ActiveSupport::Concern

  included do
    state_machine initial: :new do
      state :depositing do
        validate :correct_version
      end

      before_transition WorkObserver.method(:before_transition)

      after_transition WorkObserver.method(:after_transition)
      after_transition to: :depositing, do: WorkObserver.method(:after_begin_deposit)
      after_transition on: :reserve_purl, do: WorkObserver.method(:after_begin_reserve)
      after_transition on: :pid_assigned, do: WorkObserver.method(:after_druid_assigned)
      after_transition on: :reject, do: WorkObserver.method(:after_rejected)
      after_transition to: :pending_approval, do: WorkObserver.method(:after_submit_for_review)
      after_transition on: :deposit_complete, do: WorkObserver.method(:after_deposit_complete)
      after_transition on: :deposit_complete, do: CollectionObserver.method(:item_deposited)
      after_transition on: :decommission, do: WorkObserver.method(:after_decommission)
      after_transition on: :unzip, do: WorkObserver.method(:after_unzip)
      after_transition on: :unzip_and_submit_for_review, do: WorkObserver.method(:after_unzip)
      after_transition on: :unzip_and_begin_deposit, do: WorkObserver.method(:after_unzip)

      # sends email to user about setting up a globus account; only happens first time we transition to this state
      after_transition except_from: :globus_setup_first_draft, to: :globus_setup_first_draft,
                       do: WorkObserver.method(:globus_account_setup)
      after_transition except_from: :globus_setup_version_draft, to: :globus_setup_version_draft,
                       do: WorkObserver.method(:globus_account_setup)

      # check to see if there any globus related actions needed when transitioning to any draft state
      after_transition to: %i[first_draft version_draft globus_setup_first_draft globus_setup_version_draft],
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

      # event occurs when a user selects globus for upload but does not have a globus account yet:
      #  transition to the globus_setup state so we can show them UI elements and send emails
      event :globus_setup_pending do
        transition first_draft: :globus_setup_first_draft
        transition version_draft: :globus_setup_version_draft
      end

      # event occurs when we create the globus endpoint; go back to regular draft states (if not already there)
      event :globus_setup_complete do
        transition first_draft: :first_draft
        transition version_draft: :version_draft
        transition globus_setup_first_draft: :first_draft
        transition globus_setup_version_draft: :version_draft
      end

      # event occurs when the user aborts globus uploads and chooses a different upload method
      event :globus_setup_aborted do
        transition globus_setup_first_draft: :first_draft
        transition globus_setup_version_draft: :version_draft
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

        transition %i[first_draft version_draft pending_approval rejected globus_setup_first_draft
                      globus_setup_version_draft] => same
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

      event :no_review_workflow do
        transition %i[pending_approval rejected] => :version_draft
      end

      event :decommission do
        transition all => :decommissioned
      end
    end

    def check_globus_setup
      if globus?
        # if the user selected the globus upload option, run the globus setup job each time we save as draft
        #  to see if there is any work to be done for globus setup
        #  Note: all work happens in a job because it makes API calls to Globus which shouldn't block the HTTP cycle
        GlobusSetupJob.perform_later(self)
      elsif globus_setup_draft?
        # if this is NOT a globus upload job and we were in a globus setup pending state, go back to draft
        #  the reason is that if a user first selected globus, didn't have a globus account, and then later
        #  changed back to a different upload type, we need to get them back to the draft state
        globus_setup_aborted!
      end
    end

    def correct_version
      # Skip this check since no SDR API in dev.
      return if Rails.env.development?

      return unless work.druid

      return if Repository.valid_version?(druid: work.druid, h2_version: version)

      errors.add(:version, 'must be one greater than the version in SDR')
    end
  end
end
