# typed: false
# frozen_string_literal: true

# Models a collection in the database
class Collection < ApplicationRecord
  include Eventable

  has_many :works, dependent: :destroy
  has_many :related_links, as: :linkable, dependent: :destroy
  has_many :events, as: :eventable, dependent: :destroy
  has_many :contact_emails, as: :emailable, dependent: :destroy
  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :depositors, class_name: 'User', join_table: 'depositors'
  has_and_belongs_to_many :reviewed_by, class_name: 'User', join_table: 'reviewers'
  has_and_belongs_to_many :managed_by, class_name: 'User', join_table: 'managers'

  after_update_commit -> { broadcast_replace_to self }
  after_update_commit :broadcast_update_collection_summary

  def broadcast_update_collection_summary
    broadcast_replace_to :collection_summary, partial: 'dashboards/collection_summary'
  end

  sig { returns(T::Boolean) }
  def accessioned?
    %w[first_draft depositing].exclude?(state)
  end

  sig { returns(T.nilable(Date)) }
  def embargo_release_date
    return Time.zone.today + 6.months if release_duration == '6 months'

    Time.zone.today + release_duration.gsub(/[^\d]/, '').to_i.years
  end

  # The collection has allowed the user to specify availablity on the member works
  sig { returns(T::Boolean) }
  def user_can_set_availability?
    release_option == 'depositor-selects'
  end

  # The collection has allowed the user to select a license for the member works
  sig { returns(T::Boolean) }
  def user_can_set_license?
    license_option == 'depositor-selects'
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
