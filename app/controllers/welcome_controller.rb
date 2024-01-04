# frozen_string_literal: true

# The endpoint for the landing page
class WelcomeController < ApplicationController
  def show
    @page_content = PageContent.find_by(page: 'home')
    render :first_time if user_signed_in? && !allowed_to?(:show?, :dashboard)
  end
end
