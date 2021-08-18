# frozen_string_literal: true

# Base class for work and work_version policies
class CommonWorkPolicy < ApplicationPolicy
  alias_rule :delete?, to: :destroy?

  private

  def administors_collection?
    administrator? || depositor? || reviews_collection? || manages_collection?(collection)
  end

  def reviews_collection?
    allowed_to?(:review?, collection)
  end
end
