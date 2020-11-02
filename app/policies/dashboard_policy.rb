# typed: strict
# frozen_string_literal: true

# Defines who is authorized to see the dashboard
class DashboardPolicy < ApplicationPolicy
  sig { returns(T::Boolean) }
  def show?
    administrator? || collection_creator? # TODO: || has created any deposits
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups
end
