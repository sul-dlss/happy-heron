# frozen_string_literal: true

# Defines who is authorized to see the admin dashboard
class AdminDashboardPolicy < ApplicationPolicy
  def show?
    administrator?
  end

  def items_recent_activity?
    administrator?
  end

  def collections_recent_activity?
    administrator?
  end
end
