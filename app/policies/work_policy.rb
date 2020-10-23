# typed: strict
# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  sig { returns(T::Boolean) }
  def create?
    user.collection_creator?
  end
end
