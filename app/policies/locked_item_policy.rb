# frozen_string_literal: true

# Defines who is authorized to see the locked items (on the admin dashboard)
class LockedItemPolicy < ApplicationPolicy
  def index?
    administrator?
  end
end
