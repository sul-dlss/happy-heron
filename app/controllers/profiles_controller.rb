# frozen_string_literal: true

# Show the user profile
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def show
    authorize! :profile
    @collections = current_user.collections_with_access(deposit: false)
  end
end
