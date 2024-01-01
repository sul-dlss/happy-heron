# frozen_string_literal: true

# Defines the states and transitions for a CollectionVersion
module CollectionVersionStateMachine
  extend ActiveSupport::Concern

  included do
    state_machine initial: :new do
      before_transition do |collection_version, transition|
        event_params = collection_version.collection.event_context
        collection_version.collection.events.create!(event_params.merge(event_type: transition.event))
      end

      # rubocop:disable Rails/SkipsModelValidations
      before_transition on: :update_metadata do |collection_version, _transition|
        collection_version.touch # ensure we set the updated_at column for collection when anything changes
      end
      # rubocop:enable Rails/SkipsModelValidations

      after_transition on: :begin_deposit do |collection_version, transition|
        if transition.from == "first_draft"
          collection_version.collection.depositors.each do |depositor|
            CollectionsMailer.with(collection_version:, user: depositor)
              .invitation_to_deposit_email.deliver_later
          end

          collection_version.collection.reviewed_by.each do |reviewer|
            CollectionsMailer.with(collection_version:, user: reviewer)
              .review_access_granted_email.deliver_later
          end

          collection_version.collection.managed_by.each do |manager|
            CollectionsMailer.with(collection_version:, user: manager)
              .manage_access_granted_email.deliver_later
          end
        end
        DepositCollectionJob.perform_later(collection_version)
      end

      after_transition new: :first_draft do |collection_version|
        if Settings.notify_admin_list
          FirstDraftCollectionsMailer.with(collection_version:)
            .first_draft_created.deliver_later
        end
      end

      after_transition on: :decommission, do: CollectionObserver.method(:after_decommission)

      event :begin_deposit do
        transition %i[first_draft version_draft] => :depositing
      end

      event :deposit_complete do
        transition depositing: :deposited
      end

      event :update_metadata do
        transition new: :first_draft
        transition %i[first_draft version_draft] => same
      end

      event :decommission do
        transition all => :decommissioned
      end
    end
  end
end
