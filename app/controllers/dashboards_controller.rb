# typed: false
# frozen_string_literal: true

# Displays the list of collections to the user
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def show
    authorize! :dashboard
    @presenter = DashboardPresenter.new(
      collections: authorized_scope(Collection.all),
      drafts: Work.where(state: 'first_draft', depositor: current_user)
    )
  end
end
