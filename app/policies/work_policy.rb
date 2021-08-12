# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  alias_rule :delete?, to: :destroy?

  # Return the relation defining the collections you can view.
  scope_for :relation do |relation|
    relation.where(collection_id: user.manages_collection_ids + user.reviews_collection_ids).or(
      relation.where(depositor: user)
    )
  end

  def destroy?
    (administrator? || depositor?) && record.persisted? && (first_draft? || first_draft_in_review?)
  end

  delegate :administrator?, to: :user_with_groups

  # a first draft of a deposit or a reserved purl
  def first_draft?
    record.head.first_draft? || record.head.purl_reservation?
  end

  # a first draft of a deposit in reviewer workflow that is either pending approval or returned
  def first_draft_in_review?
    record.head.version == 1 && (record.head.pending_approval? || record.head.rejected?)
  end

  def depositor?
    record.depositor == user
  end
end
