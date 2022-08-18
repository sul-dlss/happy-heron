# frozen_string_literal: true

# Defines who is authorized to see the collection reports (admin page)
class CollectionReportPolicy < ApplicationPolicy
  def create?
    administrator?
  end

  def new?
    administrator?
  end
end
