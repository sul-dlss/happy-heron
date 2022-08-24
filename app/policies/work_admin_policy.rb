# frozen_string_literal: true

# Authorization policy for Work admins
class WorkAdminPolicy < ApplicationPolicy
  def edit_lock?
    administrator?
  end

  def update_lock?
    administrator?
  end
end
