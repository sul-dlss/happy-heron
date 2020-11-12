# typed: false
# frozen_string_literal: true

# Authorization policy for Collection objects
class CollectionPolicy < ApplicationPolicy
  # Return the relation defining the collections you can deposit into.
  scope_for :deposit do |relation|
    if administrator?
      relation.all
    else
      relation.where(creator: user_with_groups.user).or(relation.where(id: user.deposits_into_ids))
    end
  end

  alias_rule :edit?, to: :update?

  # Those who are members of the LDAP collection group may create collections
  sig { returns(T::Boolean) }
  def create?
    administrator? || collection_creator?
  end

  sig { returns(T::Boolean) }
  def update?
    administrator? || manages_collection?(record)
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups
end
