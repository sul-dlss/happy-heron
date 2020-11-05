# typed: strict
# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?

  # Only depositors in a specific collection are able to create new collection members
  sig { returns(T::Boolean) }
  def create?
    collection = record.collection
    collection.depositor_ids.include?(user.id) ||
      collection.managers.include?(user.email.delete_suffix('@stanford.edu'))
  end

  # Only the depositor may edit/update a work
  sig { returns(T::Boolean) }
  def update?
    record.depositor == user
  end
end
