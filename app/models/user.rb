# typed: strict
# frozen_string_literal: true

class User < ApplicationRecord
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false }

  has_many :notifications, dependent: :destroy

  devise :remote_user_authenticatable
end
