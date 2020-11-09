# typed: false
# frozen_string_literal: true

# Authorization policy for Collection objects
class CollectionPolicy < ApplicationPolicy
  relation_scope do |relation|
    relation.where(creator: user_with_groups.user)
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
