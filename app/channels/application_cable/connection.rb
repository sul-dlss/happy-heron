# typed: strict
# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    extend T::Sig

    identified_by :current_user

    sig { returns(User) }
    def connect
      self.current_user = user_from_session
    end

    private

    sig { returns(User) }
    def user_from_session
      env['warden'].user || reject_unauthorized_connection
    end
  end
end
