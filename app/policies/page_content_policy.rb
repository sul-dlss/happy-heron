# frozen_string_literal: true

# Defines who is authorized to see the page content update (admin page)
class PageContentPolicy < ApplicationPolicy
  alias_rule :update?, to: :index?
  alias_rule :edit?, to: :index?

  def index?
    administrator?
  end
end
