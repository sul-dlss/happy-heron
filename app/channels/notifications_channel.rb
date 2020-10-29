# typed: false
# frozen_string_literal: true

# An ApplicationCable channel for sending notifications to a user
class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications:#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
