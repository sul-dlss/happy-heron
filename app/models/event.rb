# frozen_string_literal: true

# Records events in the lifecycle of a deposit
class Event < ApplicationRecord
  default_scope { order(created_at: :desc) }
  belongs_to :eventable, polymorphic: true
  belongs_to :user, optional: true

  scope :work_events, -> { where(eventable_type: 'Work') }
  scope :collection_events, -> { where(eventable_type: 'Collection') }

  def self.latest_by_type(type)
    where(event_type: type).order('created_at DESC').limit(1).first
  end
end
