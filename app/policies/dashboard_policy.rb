# typed: strict
# frozen_string_literal: true

# Defines who is authorized to see the dashboard
class DashboardPolicy < ApplicationPolicy
  sig { returns(T::Boolean) }
  def show?
    user.application_user?
  end
end
