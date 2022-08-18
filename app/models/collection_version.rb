# frozen_string_literal: true

# Models a version of a collection in the database
class CollectionVersion < ApplicationRecord
  include AggregateAssociations

  has_many :related_links, as: :linkable, dependent: :destroy
  has_many :contact_emails, as: :emailable, dependent: :destroy
  belongs_to :collection

  after_update_commit -> { collection.broadcast_update }

  def accessioned?
    %w[first_draft depositing].exclude?(state)
  end

  state_machine initial: :new do
    before_transition do |collection_version, transition|
      event_params = collection_version.collection.event_context
      collection_version.collection.events.create(event_params.merge(event_type: transition.event))
    end

    after_transition on: :begin_deposit do |collection_version, transition|
      if transition.from == 'first_draft'
        collection_version.collection.depositors.each do |depositor|
          CollectionsMailer.with(collection_version: collection_version, user: depositor)
                           .invitation_to_deposit_email.deliver_later
        end

        collection_version.collection.reviewed_by.each do |reviewer|
          CollectionsMailer.with(collection_version: collection_version, user: reviewer)
                           .review_access_granted_email.deliver_later
        end

        collection_version.collection.managed_by.each do |manager|
          CollectionsMailer.with(collection_version: collection_version, user: manager)
                           .manage_access_granted_email.deliver_later
        end
      end
      DepositCollectionJob.perform_later(collection_version)
    end

    after_transition new: :first_draft do |collection_version|
      if Settings.notify_admin_list
        FirstDraftCollectionsMailer.with(collection_version: collection_version)
                                   .first_draft_created.deliver_later
      end
    end

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
  end

  def updatable?
    can_update_metadata? || (deposited? && head?)
  end

  def draft?
    version_draft? || first_draft?
  end

  def head?
    collection.head == self
  end
end
