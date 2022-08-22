# frozen_string_literal: true

module Admin
  # Defines who is authorized to see the item reports (admin page)
  class WorkReportPolicy < ApplicationPolicy
    alias_rule :new?, to: :create?

    def create?
      administrator?
    end
  end
end
