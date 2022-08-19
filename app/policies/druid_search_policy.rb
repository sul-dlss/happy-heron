# frozen_string_literal: true

# Defines who is authorized to see the druid search (admin page)
class DruidSearchPolicy < ApplicationPolicy
  def index?
    administrator?
  end
end
