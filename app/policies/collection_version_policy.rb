# typed: strict
# frozen_string_literal: true

# Authorization policy for Collection objects
class CollectionVersionPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?
  alias_rule :delete?, to: :destroy?

  sig { returns(T::Boolean) }
  def update?
    return false unless record.updatable?

    allowed_to?(:update?, record.collection)
  end

  sig { returns(T::Boolean) }
  def show?
    allowed_to?(:show?, record.collection)
  end

  sig { returns(T::Boolean) }
  def destroy?
    (administrator? || manages_collection?(record.collection)) && record.persisted? && record.version_draft?
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups
  delegate :collection, to: :record
end
