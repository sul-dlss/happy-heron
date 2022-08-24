# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  alias_rule :delete?, to: :destroy?

  # Return the relation defining the collections you can view and removing decommissioned works unless administrator.
  scope_for :relation do |relation|
    new_relation = relation.where(collection_id: user.manages_collection_ids + user.reviews_collection_ids).or(
      relation.where(owner: user)
    )
    return new_relation if administrator?

    relation.joins(:head).where.not(head: { state: 'decommissioned' }).and(new_relation)
  end

  def destroy?
    (allowed_to?(:review?, collection) || owner_of_the_work?) && record.persisted? && record.head.deleteable?
  end

  delegate :administrator?, to: :user_with_groups
  delegate :collection, to: :record

  def owner_of_the_work?
    record.owner == user
  end
end
