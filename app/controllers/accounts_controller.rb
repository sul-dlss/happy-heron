# frozen_string_literal: true

# Looks up data for sunets from the UIT account service
class AccountsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def show
    authorize! :account
    render json: lookup
  end

  private

  # Does a lookup from the account service in production mode, otherwise returns a stub value
  def lookup
    return AccountService.new.fetch(params[:id]) if Rails.env.production?
    return {} if params[:id].size < 6

    {
      'name' => 'Coyne, Justin Michael',
      'description' => 'Digital Library Systems and Services, Digital Library Software Engineer - Web & Infrastructure'
    }
  end
end