# frozen_string_literal: true

module ApplicationCable
  # Represents an authorized ActionCable connection
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = user_from_session
    end

    private

    def user_from_session
      env["warden"].user || reject_unauthorized_connection
    end
  end
end
