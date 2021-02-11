# typed: false
# frozen_string_literal: true

# Models the deposit of an digital repository object in H2.
class Work < ApplicationRecord
  include Eventable

  belongs_to :collection
  belongs_to :depositor, class_name: 'User'
  belongs_to :head, class_name: 'WorkVersion', optional: true

  has_many :events, as: :eventable, dependent: :destroy

  def broadcast_update
    broadcast_replace_to self
  end

  sig { returns(T.nilable(String)) }
  def purl
    return nil unless druid

    File.join(Settings.purl_url, T.must(druid).delete_prefix('druid:'))
  end

  # This ensures that action-policy doesn't think that every 'Work.new' is the same.
  # This supports the following:
  #   allowed_to :create?, Work.new(collection:collection)
  sig { returns(T.any(String, Integer)) }
  def policy_cache_key
    persisted? ? cache_key : object_id
  end

  sig { returns(T.nilable(String)) }
  def last_rejection_description
    events.latest_by_type('reject')&.description
  end

  delegate :name, to: :collection, prefix: true
  delegate :name, to: :depositor, prefix: true

  private

  sig { override.returns(T::Hash[Symbol, String]) }
  def default_event_context
    { user: depositor }
  end
end
