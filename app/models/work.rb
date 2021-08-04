# typed: false
# frozen_string_literal: true

# Models the deposit of an digital repository object in H2.
class Work < ApplicationRecord
  include Eventable

  belongs_to :collection
  belongs_to :depositor, class_name: 'User'
  belongs_to :head, class_name: 'WorkVersion', optional: true

  has_many :events, as: :eventable, dependent: :destroy
  has_many :work_versions, dependent: :destroy

  def broadcast_update
    broadcast_replace_to self
    broadcast_replace_to :summary_rows, partial: 'dashboards/collection_summary_row'
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

  def collection_name
    collection.head.name
  end

  sig { returns(T.nilable(T::Boolean)) }
  def already_immediately_released?
    head&.deposited? && head.embargo_date.nil?
  end

  sig { returns(T.nilable(T::Boolean)) }
  def already_embargo_released?
    head&.deposited? && head.embargo_date.present? && head.embargo_date < Time.zone.today
  end

  delegate :name, to: :depositor, prefix: true
  delegate :purl_reservation?, to: :head

  private

  sig { override.returns(T::Hash[Symbol, String]) }
  def default_event_context
    { user: depositor }
  end
end
