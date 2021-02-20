# typed: strict
# frozen_string_literal: true

# Authorization policy for Collection objects
class CollectionVersionPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?
  alias_rule :delete?, to: :destroy?

  sig { returns(T::Boolean) }
  def update?
    return false unless record.updatable?

    administrator? || manages_collection?(record.collection)
  end

  sig { returns(T::Boolean) }
  def show?
    administrator? ||
      collection.managed_by.include?(user) ||
      collection.reviewed_by.include?(user) ||
      collection.depositor_ids.include?(user.id)
  end

  sig { returns(T::Boolean) }
  def destroy?
    (administrator? || manages_collection?(record.collection)) && record.persisted? && record.version_draft?
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups
  delegate :collection, to: :record
end
