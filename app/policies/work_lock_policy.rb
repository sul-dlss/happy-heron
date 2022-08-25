# frozen_string_literal: true

# Authorization policy for Work admins to lock/unlock
class WorkLockPolicy < ApplicationPolicy
  def edit?
    administrator?
  end

  def update?
    administrator?
  end
end
