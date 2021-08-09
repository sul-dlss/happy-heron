# frozen_string_literal: true

# Defines who is authorized to see the dashboard
class DashboardPolicy < ApplicationPolicy
  def show?
    # If/when we add the designed "first time user" workflow, we would want to prevent
    # users who don't have any deposits from going right to the dashboard. As of
    # Feb 2021, we haven't had time to do that so we allow any user who is a depositor
    # in any collection.
    # administrator? || collection_creator? || user.deposits.any? ||
    #   user.reviews_collections.any? || user.manages_collections.any?
    administrator? || collection_creator? || user.deposits_into.any? ||
      user.reviews_collections.any? || user.manages_collections.any?
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups
end
