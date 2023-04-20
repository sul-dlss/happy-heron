# frozen_string_literal: true

# Defines who is authorized to see the page content update (admin page)
class PageContentPolicy < ApplicationPolicy
  def index?
    administrator?
  end

  def update?
    administrator?
  end
end
