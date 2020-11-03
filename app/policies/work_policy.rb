# typed: strict
# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  sig { returns(T::Boolean) }

  # Only depositors in a specific collection are able to create new collection members
  def create?
    collection = record.collection
    collection.depositor_ids.include?(user.id) ||
      collection.managers.include?(user.email.delete_suffix('@stanford.edu'))
  end
end
