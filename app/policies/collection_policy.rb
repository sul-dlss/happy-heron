# frozen_string_literal: true

# Authorization policy for Collection objects
class CollectionPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?
  alias_rule :delete?, to: :destroy?

  # Return the relation defining the collections you can deposit into, manage or review.
  relation_scope :deposit do |relation|
    relation.where(id: user.deposits_into_ids + user.manages_collection_ids + user.reviews_collection_ids)
  end

  def update?
    administrator? || manages_collection?(record)
  end

  def show?
    administrator? || manages_collection?(record) ||
      reviews_collection? ||
      record.depositor_ids.include?(user.id)
  end

  def destroy?
    (administrator? || manages_collection?(record)) && record.persisted? && record.head.first_draft?
  end

  # Those who are members of the LDAP collection group may create collections

  def create?
    administrator? || collection_creator?
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups

  def review?
    administrator? ||
      manages_collection?(record) ||
      reviews_collection?
  end

  private

  def reviews_collection?
    record.reviewed_by.include?(user)
  end
end
