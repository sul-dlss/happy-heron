# frozen_string_literal: true

# Authorization policy for lookup of accounts
class AccountPolicy < ApplicationPolicy
  def show?
    administrator? || collection_creator? || manages_any_collection?
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups

  private

  def manages_any_collection?
    user_with_groups.user.manages_collections.any?
  end
end
