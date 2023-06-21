# frozen_string_literal: true

# Authorization policy for Collection objects
class CollectionVersionPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?
  alias_rule :delete?, to: :destroy?

  # Return the relation defining the collections you can view and removing decommissioned works unless administrator.
  scope_for :relation do |relation|
    return relation if administrator?

    relation.where.not(state: "decommissioned").and(
      relation.where(
        collection_id: user.deposits_into_ids + user.manages_collection_ids + user.reviews_collection_ids
      )
    )
  end

  def update?
    return false unless record.updatable?

    allowed_to?(:update?, record.collection)
  end

  def show?
    allowed_to?(:show?, record.collection)
  end

  def destroy?
    (administrator? || manages_collection?(record.collection)) && record.persisted? && record.version_draft?
  end

  def deposit?
    record.updatable? && show?
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups
  delegate :collection, to: :record
end
