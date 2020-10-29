# typed: strict
# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  sig { returns(T::Boolean) }

  # TODO: Only depositors in a specific collection should be able to deposit
  def create?
    true
  end
end
