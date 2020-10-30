# typed: false
# frozen_string_literal: true

# Displays the list of collections to the user
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def show
    authorize! :dashboard
    @collections = authorized_scope(Collection.all)
  end
end
