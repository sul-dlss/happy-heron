# frozen_string_literal: true

# Authorization policy for lookup of accounts
class AccountPolicy < ApplicationPolicy
  def show?
    administrator? || collection_creator?
  end

  delegate :administrator?, :collection_creator?, to: :user_with_groups
end
