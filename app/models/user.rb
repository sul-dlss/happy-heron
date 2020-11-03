# typed: strict
# frozen_string_literal: true

# Models a user of the system
class User < ApplicationRecord
  extend T::Sig

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false }

  has_many :notifications, dependent: :destroy

  devise :remote_user_authenticatable

  sig { returns(String) }
  def to_s
    email
  end
end
