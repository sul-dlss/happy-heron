# typed: strict
# frozen_string_literal: true

# Represents a user and their groups
class UserWithGroups
  extend T::Sig

  sig { params(user: User, groups: T::Array[String]).void }
  def initialize(user:, groups:)
    @user = user
    @groups = groups
  end

  sig { returns(User) }
  attr_reader :user

  sig { returns(T::Array[String]) }
  attr_reader :groups

  sig { returns(T::Boolean) }
  def administrator?
    groups.include?(Settings.authorization_workgroup_names.administrators)
  end

  sig { returns(T::Boolean) }
  def collection_creator?
    groups.include?(Settings.authorization_workgroup_names.collection_creators)
  end
end
