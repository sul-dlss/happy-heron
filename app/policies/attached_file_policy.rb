# frozen_string_literal: true

# Authorization policy for AttacheFile objects
class AttachedFilePolicy < ApplicationPolicy
  def show?
    allowed_to?(:show?, record.work_version)
  end
end
