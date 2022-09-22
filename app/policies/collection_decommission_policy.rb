# frozen_string_literal: true

# Authorization policy for Collection decommission operations
class CollectionDecommissionPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?

  def update?
    administrator?
  end
end
