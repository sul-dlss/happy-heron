# typed: strict
# frozen_string_literal: true

# The endpoint for the landing page
class WelcomeController < ApplicationController
  private

  sig { returns(T::Boolean) }
  def show_breadcrumbs?
    false
  end
end
