# typed: false
# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?

  relation_scope :edits do |scope|
    scope.where(depositor: user)
         .or(scope.where(collection_id: [user.manages_collection_ids + user.reviews_collection_ids]))
  end

  # Can deposit a work iff:
  #   1. Collection is accessioned
  #   2. The user is an administrator, or a depositor or a manager of this collection
  sig { returns(T::Boolean) }
  def create?
    collection = record.collection
    return false unless collection.accessioned?

    return true if administrator?

    (collection.depositor_ids.include?(user.id) || manages_collection?(collection))
  end

  # Only the depositor may edit/update a work if it is not in review
  sig { returns(T::Boolean) }
  def update?
    return false unless record.can_update_metadata?

    !record.pending_approval? && (administrator? || record.depositor == user)
  end

  # The collection reviewers can review a work
  sig { returns(T::Boolean) }
  def review?
    record.pending_approval? && (administrator? || record.collection.reviewers.include?(user))
  end

  delegate :administrator?, to: :user_with_groups
end
