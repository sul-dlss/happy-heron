# frozen_string_literal: true

module Admin
  # Defines who is authorized to see the item reports (admin page)
  class WorkReportPolicy < ApplicationPolicy
    def create?
      administrator?
    end

    def new?
      administrator?
    end
  end
end
