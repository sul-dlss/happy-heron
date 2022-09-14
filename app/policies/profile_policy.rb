# frozen_string_literal: true

# Defines who is authorized to see the profile screen
class ProfilePolicy < ApplicationPolicy
  def show?
    administrator? || manages_any_collection? || reviews_any_collection?
  end

  private

  def manages_any_collection?
    user_with_groups.user.manages_collections.any?
  end

  def reviews_any_collection?
    user_with_groups.user.reviews_collections.any?
  end
end
