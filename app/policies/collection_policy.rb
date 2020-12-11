# typed: false
# frozen_string_literal: true

# Authorization policy for Collection objects
class CollectionPolicy < ApplicationPolicy
  # Return the relation defining the collections you can deposit into, manage or review.
  relation_scope :deposit do |relation|
    relation.where(id: user.deposits_into_ids + user.manages_collection_ids + user.reviews_collection_ids)
  end

  alias_rule :edit?, to: :update?
  alias_rule :delete?, to: :destroy?

  # Those who are members of the LDAP collection group may create collections
  sig { returns(T::Boolean) }
  def create?
    administrator? || collection_creator?
  end

  sig { returns(T::Boolean) }
  def update?
    return false unless record.can_update_metadata?

    administrator? || manages_collection?(record)
  end

  sig { returns(T::Boolean) }
  def show?
    administrator? ||
      record.managers.include?(user) ||
      record.reviewers.include?(user) ||
      record.depositor_ids.include?(user.id)
  end

  sig { returns(T::Boolean) }
  def destroy?
    (administrator? || collection_creator?) && record.persisted? && record.first_draft?
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups
end
