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
      after_transition on: :begin_deposit do |work_version, transition|
        work_version.update_attribute(:published_at, DateTime.now.utc) # rubocop:disable Rails/SkipsModelValidations
        WorkObserver.after_begin_deposit(work_version, transition)
      end
      after_transition on: :reserve_purl, do: WorkObserver.method(:after_begin_reserve)
      after_transition on: :pid_assigned, do: WorkObserver.method(:after_druid_assigned)
      after_transition on: :reject, do: WorkObserver.method(:after_rejected)
      after_transition on: :submit_for_review, do: WorkObserver.method(:after_submit_for_review)
      after_transition on: :deposit_complete, do: WorkObserver.method(:after_deposit_complete)
      after_transition on: :deposit_complete, do: CollectionObserver.method(:item_deposited)
      after_transition on: :decommission, do: WorkObserver.method(:after_decommission)

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

      event :no_review_workflow do
        transition %i[pending_approval rejected] => :version_draft
      end

      event :decommission do
        transition all => :decommissioned
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
