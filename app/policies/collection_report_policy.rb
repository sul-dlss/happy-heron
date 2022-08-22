# frozen_string_literal: true

# Defines who is authorized to see the collection reports (admin page)
class CollectionReportPolicy < ApplicationPolicy
  alias_rule :new?, to: :create?

  def create?
    administrator?
  end
end
