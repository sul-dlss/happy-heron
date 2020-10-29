# typed: strict
# frozen_string_literal: true

# Models a user of the system
class User < ApplicationRecord
  extend T::Sig

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false }

  has_many :notifications, dependent: :destroy

  sig { params(groups: T.nilable(T::Array[String])).returns(T.nilable(T::Array[String])) }
  attr_writer :groups

  devise :remote_user_authenticatable

  sig { returns(T::Boolean) }
  def administrator?
    groups.include?(Settings.authorization_workgroup_names.administrators)
  end

  sig { returns(T::Boolean) }
  def collection_creator?
    groups.include?(Settings.authorization_workgroup_names.collection_creators)
  end

  sig { returns(T::Array[String]) }
  def groups
    @groups || []
  end

  sig { returns(String) }
  def to_s
    email
  end
end
