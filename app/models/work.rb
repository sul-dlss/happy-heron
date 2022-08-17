# frozen_string_literal: true

# Models the deposit of an digital repository object in H2.
class Work < ApplicationRecord
  include Eventable

  belongs_to :collection
  belongs_to :depositor, class_name: 'User'
  # When created the owner is the depositor, but this can be changed so that someone else can manage the work.
  belongs_to :owner, class_name: 'User'
  belongs_to :head, class_name: 'WorkVersion', optional: true

  has_many :events, as: :eventable, dependent: :destroy
  has_many :work_versions, dependent: :destroy

  def broadcast_update
    broadcast_replace_to self
    broadcast_replace_to :summary_rows, partial: 'dashboards/collection_summary_row'
  end

  def purl
    return nil unless druid

    File.join(Settings.purl_url, druid_without_namespace)
  end

  def druid_without_namespace
    druid&.delete_prefix('druid:')
  end

  # This ensures that action-policy doesn't think that every 'Work.new' is the same.
  # This supports the following:
  #   allowed_to :create?, Work.new(collection:collection)

  def policy_cache_key
    persisted? ? cache_key : object_id
  end

  def last_rejection_description
    events.latest_by_type('reject')&.description
  end

  def collection_name
    collection.head.name
  end

  def already_immediately_released?
    head&.deposited? && head.embargo_date.nil?
  end

  def already_embargo_released?
    head&.deposited? && head.embargo_date.present? && head.embargo_date <= Time.zone.today
  end

  delegate :name, to: :depositor, prefix: true
  delegate :purl_reservation?, to: :head

  private

  def default_event_context
    { user: depositor }
  end
end
