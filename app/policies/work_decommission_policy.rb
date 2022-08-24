# frozen_string_literal: true

# Authorization policy for Work owners
class WorkDecommissionPolicy < ApplicationPolicy
  def edit?
    administrator?
  end

  def update?
    administrator?
  end
end
