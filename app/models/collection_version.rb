# typed: false
# frozen_string_literal: true

# Models a version of a collection in the database
class CollectionVersion < ApplicationRecord
  include AggregateAssociations

  has_many :related_links, as: :linkable, dependent: :destroy
  has_many :contact_emails, as: :emailable, dependent: :destroy
  belongs_to :collection

  after_update_commit -> { collection.broadcast_update }
  after_update_commit -> { collection.broadcast_update_collection_summary }

  sig { returns(T::Boolean) }
  def accessioned?
    %w[first_draft depositing].exclude?(state)
  end

  state_machine initial: :new do
    before_transition do |collection_version, transition|
      # filters out bits of the context that don't go into the event, e.g.: :change_set
      event_params = collection_version.collection.event_context.slice(:user)
      change_set = collection_version.collection.event_context.fetch(:change_set, nil)
      event_params[:description] = change_set.participant_change_description if change_set&.participants_changed?
      collection_version.collection.events.create(event_params.merge(event_type: transition.event))
    end

    after_transition on: :begin_deposit do |collection_version, transition|
      if transition.from == 'first_draft'
        collection_version.collection.depositors.each do |depositor|
          CollectionsMailer.with(collection: collection_version.collection, user: depositor)
                           .invitation_to_deposit_email.deliver_later
        end

        collection_version.collection.reviewed_by.each do |reviewer|
          CollectionsMailer.with(collection: collection_version.collection, user: reviewer)
                           .review_access_granted_email.deliver_later
        end
      end
      DepositCollectionJob.perform_later(collection_version)
    end

    after_transition to: :version_draft, do: CollectionObserver.method(:after_update_published)

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
end
