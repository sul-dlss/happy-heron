# typed: strict
# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  extend T::Sig
  authorize :user_with_groups

  private

  sig { params(collection: Collection).returns(T::Boolean) }
  def manages_collection?(collection)
    collection.managed_by.include?(user)
  end
end
