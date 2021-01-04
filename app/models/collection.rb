# typed: false
# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  include Eventable

  has_many :works, dependent: :destroy
  has_many :related_links, as: :linkable, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :depositors, class_name: 'User', join_table: 'depositors'
  has_and_belongs_to_many :reviewed_by, class_name: 'User', join_table: 'reviewers'
  has_and_belongs_to_many :managers, class_name: 'User', join_table: 'managers'

  validates :contact_email, format: { with: Devise.email_regexp }, allow_blank: true

  sig { returns(T::Boolean) }
  def review_enabled?
    reviewed_by.present?
  end

  sig { returns(T::Boolean) }
  def accessioned?
    %w[first_draft depositing].exclude?(state)
  end

  sig { returns(T.nilable(String)) }
  def purl
    return nil unless druid

    File.join(Settings.purl_url, T.must(druid).delete_prefix('druid:'))
  end

  state_machine initial: :new do
    before_transition do |collection, transition|
      # filters out bits of the context that don't go into the event, e.g.: :change_set
      event_params = collection.event_context.slice(:user)
      change_set = collection.event_context.fetch(:change_set, nil)
      event_params[:description] = change_set.participant_change_description if change_set&.participants_changed?
      collection.events.build(event_params.merge(event_type: transition.event))
    end

    after_transition on: :begin_deposit do |collection, transition|
      if transition.from == 'first_draft'
        collection.depositors.each do |depositor|
          CollectionsMailer.with(collection: collection, user: depositor)
                           .invitation_to_deposit_email.deliver_later
        end

        collection.reviewed_by.each do |reviewer|
          CollectionsMailer.with(collection: collection, user: reviewer)
                           .review_access_granted_email.deliver_later
        end
      end
      DepositCollectionJob.perform_later(collection)
    end

    after_transition to: :version_draft, do: CollectionObserver.method(:after_update_published)

    after_transition do |collection, transition|
      BroadcastCollectionChange.call(collection: collection, state: transition.to_name)
    end

    event :begin_deposit do
      transition %i[first_draft version_draft] => :depositing
    end

    event :deposit_complete do
      transition depositing: :deposited
    end

    event :update_metadata do
      transition new: :first_draft
      transition deposited: :version_draft
      transition %i[first_draft version_draft] => same
    end
  end

  private

  sig { override.returns(T::Hash[Symbol, String]) }
  def default_event_context
    { user: creator }
  end
end
