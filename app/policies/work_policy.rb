# typed: false
# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?

  relation_scope :depositor do |scope|
    scope.where(depositor: user)
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

  # Can edit a work iff:
  #   1. The work is in a state where it can be updated (e.g. not depositing)
  #   2. The user is an administrator, the depositor of the work, or a manager of the collection the work is in.
  sig { returns(T::Boolean) }
  def update?
    return false unless record.can_update_metadata?

    administrator? || record.depositor == user || record.collection.managers.include?(user)
  end

  # The collection reviewers can review a work
  sig { returns(T::Boolean) }
  def review?
    record.pending_approval? && (administrator? || record.collection.reviewers.include?(user))
  end

  delegate :administrator?, to: :user_with_groups
end
