# frozen_string_literal: true

# Defines who is authorized to see the admin dashboard
class AdminDashboardPolicy < ApplicationPolicy
  alias_rule :index?, to: :show?

  def show?
    administrator?
  end

  delegate :administrator?, to: :user_with_groups
end
