# frozen_string_literal: true

# Defines who is authorized to see the admin dashboard
class AdminDashboardPolicy < ApplicationPolicy
  def show?
    administrator?
  end
end
