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

  # TODO: don't allow everyone to update collections (https://github.com/sul-dlss/happy-heron/issues/254)
  sig { returns(T::Boolean) }
  def update?
    true
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups
end
