# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  authorize :user_with_groups

  private

  def manages_collection?(collection)
    collection.managed_by.include?(user)
  end

  delegate :administrator?, to: :user_with_groups
end
