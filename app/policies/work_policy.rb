# typed: false
# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?

  relation_scope :depositor do |scope|
    scope.where(depositor: user)
  end

  # Only depositors in a specific collection are able to create new collection members
  sig { returns(T::Boolean) }
  def create?
    collection = record.collection
    collection.depositor_ids.include?(user.id) || manages_collection?(collection)
  end

  # Only the depositor may edit/update a work if it is not in review
  sig { returns(T::Boolean) }
  def update?
    record.depositor == user && !record.pending_approval?
  end

  # The collection reviewers can review a work
  sig { returns(T::Boolean) }
  def review?
    record.pending_approval? && record.collection.reviewers.include?(user)
  end
end
