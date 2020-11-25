# typed: strict
# frozen_string_literal: true

# Triggers state changes, logs events, and broadcasts changes
class EventService
  extend T::Sig

  class << self
    include ActionView::Helpers::UrlHelper
  end

  sig { params(work: Work, user: User, description: String).returns(T.nilable(Integer)) }
  def self.reject(work:, user:, description:)
    work.reject!
    Event.create!(work: work, user: user, event_type: 'reject', description: description)
    WorkUpdatesChannel.broadcast_to(work, state: current_state_display_label(work))
  end

  sig { params(work: Work, user: User, description: String).returns(T.nilable(Integer)) }
  def self.begin_deposit(work:, user:, description: '')
    work.begin_deposit!
    Event.create!(work: work, user: user, event_type: 'begin_deposit', description: description)
    WorkUpdatesChannel.broadcast_to(work, state: current_state_display_label(work))
  end

  sig { params(work: Work, user: User).returns(T.nilable(Integer)) }
  def self.submit_for_review(work:, user:)
    work.submit_for_review!
    Event.create!(work: work, user: user, event_type: 'submit_for_review')
    WorkUpdatesChannel.broadcast_to(work, state: current_state_display_label(work))
  end

  sig { params(work: Work).returns(T.nilable(String)) }
  def self.current_state_display_label(work)
    Works::StateDisplayComponent.new(work: work).call
  end
end
