# frozen_string_literal: true

# Simple controller to handle login and redirect
class LoginController < ApplicationController
  def login
    # Only hit after successful Shibboleth authN, so let warden know the user is copacetic.
    warden.authenticate(scope: :user)

    if session[:user_return_to].present?
      redirect_to session[:user_return_to]
    else
      redirect_back fallback_location: root_url
    end
  end
end
