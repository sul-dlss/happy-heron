# typed: strict
# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  sig { returns(T::Boolean) }
  def show?
    user.application_user?
  end
end
