# typed: strict
# frozen_string_literal: true

# Records events in the lifecycle of a deposit
class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true
  belongs_to :user, optional: true

  sig { params(type: String).returns(T.nilable(Event)) }
  def self.latest_by_type(type)
    where(event_type: type).order('created_at DESC').limit(1).first
  end
end
