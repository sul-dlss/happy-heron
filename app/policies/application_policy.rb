# typed: strict
# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  extend T::Sig
  authorize :user_with_groups

  # private
  #
  # Define shared methods useful for most policies.
  # For example:
  #
  #  def owner?
  #    record.user_id == user.id
  #  end
end
