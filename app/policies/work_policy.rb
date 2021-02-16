# typed: false
# frozen_string_literal: true

# Authorization policy for Work objects
class WorkPolicy < ApplicationPolicy
  alias_rule :delete?, to: :destroy?

  sig { returns(T::Boolean) }
  def destroy?
    (administrator? || depositor?) && record.persisted? && record.head.first_draft?
  end

  delegate :administrator?, to: :user_with_groups

  def depositor?
    record.depositor == user
  end
end
