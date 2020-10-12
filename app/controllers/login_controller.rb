# typed: false
# frozen_string_literal: true

# Simple controller to handle login and redirect
class LoginController < ApplicationController
  def login
    # We hit this controller after hitting Shibboleth successfully, so let warden know we're copacetic.
    warden.authenticate(scope: :user)

    if params[:referrer].present?
      redirect_to params[:referrer]
    elsif session[:user_return_to].present?
      redirect_to session[:user_return_to]
    else
      redirect_back fallback_location: root_url
    end
  end
end
