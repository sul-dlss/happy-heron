# frozen_string_literal: true

# Authorization policy for Work admins to lock/unlock
class WorkLockPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?

  def update?
    administrator?
  end
end
