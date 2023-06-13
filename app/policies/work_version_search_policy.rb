# frozen_string_literal: true

# Defines who is authorized to see the work version search (admin page)
class WorkVersionSearchPolicy < ApplicationPolicy
  def index?
    administrator?
  end
end
