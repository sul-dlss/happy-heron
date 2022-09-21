# frozen_string_literal: true

# Authorization policy for changing Work collections
class WorkMovePolicy < ApplicationPolicy
  def search?
    administrator?
  end
end
