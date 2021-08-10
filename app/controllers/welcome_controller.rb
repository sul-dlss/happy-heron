# frozen_string_literal: true

# The endpoint for the landing page
class WelcomeController < ApplicationController
  def show
    return render :first_time if user_signed_in? && !allowed_to?(:show?, :dashboard)
  end
end
