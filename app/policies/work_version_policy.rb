# frozen_string_literal: true

# Authorization policy for WorkVersion objects
class WorkVersionPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?
  alias_rule :delete?, to: :destroy?
  alias_rule :details?, to: :show?

  relation_scope :edits do |scope|
    if administrator?
      scope
    else
      scope.joins(:head).where.not(head: { state: 'decommissioned' }).and(
        scope.where(owner: user)
        .or(scope.where(collection_id: [user.manages_collection_ids + user.reviews_collection_ids]))
      )
    end
  end

  # Can deposit a work iff:
  #   1. Collection is accessioned
  #   2. The user is an administrator, or a depositor or a manager of this collection
  def create?
    return false unless collection.head.accessioned?
    return true if administrator?

    (collection.depositor_ids.include?(user.id) || manages_collection?(collection))
  end

  def update_type?
    record.purl_reservation? && update?
  end

  # Can edit a work iff:
  #   The work is in a state where it can be updated
  #     (e.g. not depositing, not an in-progress purl reservation, not locked)
  #   AND if any one of the following is true:
  #     1. The user is an administrator
  #     2. The user is the depositor of the work and it is not currently pending approval (review workflow)
  #     3. The user is a manager of the collection the work is in
  #     4. The user is a reviewer of the collection the work is in
  def update?
    return false if record.work.locked?
    return false unless record.updatable?
    return true if allowed_to?(:review?, collection)

    owner_of_the_work? && !record.pending_approval?
  end

  # Can show a work iff any one of the following is true:
  #   1. The user is an administrator
  #   2. The user is the depositor of the work
  #   3. The user is a manager of the collection the work is in
  #   4. The user is a reviewer of the collection the work is in
  def show?
    owner_of_the_work? || allowed_to?(:review?, collection)
  end

  # The collection reviewers can review a work

  def review?
    record.pending_approval? && allowed_to?(:review?, collection) && !record.work.locked?
  end

  def destroy?
    (allowed_to?(:review?, collection) || owner_of_the_work?) &&
      record.persisted? && record.draft? && !record.work.locked?
  end

  private

  delegate :administrator?, to: :user_with_groups

  def collection
    record.work.collection
  end

  def owner_of_the_work?
    record.work.owner == user
  end
end
