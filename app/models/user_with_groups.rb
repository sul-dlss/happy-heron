# frozen_string_literal: true

# Represents a user and their groups
class UserWithGroups
  def initialize(user:, groups:)
    @user = user
    @groups = groups
  end

  attr_reader :user

  attr_reader :groups

  def administrator?
    groups.include?(Settings.authorization_workgroup_names.administrators)
  end

  def collection_creator?
    groups.include?(Settings.authorization_workgroup_names.collection_creators)
  end
end
