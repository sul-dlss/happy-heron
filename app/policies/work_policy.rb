# typed: false
# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?
  alias_rule :delete?, to: :destroy?

  relation_scope :edits do |scope|
    if administrator?
      scope
    else
      scope.where(depositor: user)
           .or(scope.where(collection_id: [user.manages_collection_ids + user.reviews_collection_ids]))
    end
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
  #   The work is in a state where it can be updated (e.g. not depositing)
  #   AND if any one of the following is true:
  #     1. The user is an administrator
  #     2. The user is the depositor of the work
  #     3. The user is a manager of the collection the work is in
  #     4. The user is a reviewer of the collection the work is in
  sig { returns(T::Boolean) }
  def update?
    return false unless record.can_update_metadata?

    administrator? ||
      record.depositor == user ||
      record.collection.managers.include?(user) ||
      record.collection.reviewers.include?(user)
  end

  # Can show a work iff any one of the following is true:
  #   1. The user is an administrator
  #   2. The user is the depositor of the work
  #   3. The user is a manager of the collection the work is in
  #   4. The user is a reviewer of the collection the work is in
  sig { returns(T::Boolean) }
  def show?
    administrator? ||
      record.depositor == user ||
      record.collection.managers.include?(user) ||
      record.collection.reviewers.include?(user)
  end

  # The collection reviewers can review a work
  sig { returns(T::Boolean) }
  def review?
    record.pending_approval? && (administrator? || record.collection.reviewers.include?(user))
  end

  sig { returns(T::Boolean) }
  def destroy?
    (administrator? || record.depositor == user) && record.persisted? && record.first_draft?
  end

  delegate :administrator?, to: :user_with_groups
end
