# frozen_string_literal: true

# Authorization policy for Work owners
class WorkOwnerPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?

  def update?
    administrator?
  end
end
