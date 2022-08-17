# frozen_string_literal: true

# Displays the admin page
class AdminsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def show
    authorize! :admin_dashboard
    @presenter = AdminPresenter.new
  end
end
