# frozen_string_literal: true

# Defines who is authorized to see the user details (admin page)
class UserPolicy < ApplicationPolicy
  def index?
    administrator?
  end
end
