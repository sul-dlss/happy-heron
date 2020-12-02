# typed: false
# frozen_string_literal: true

# Displays the list of collections to the user
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def show
    authorize! :dashboard
    @presenter = DashboardPresenter.new(
      collections: authorized_scope(Collection.all, as: :deposit),
      approvals: Work.with_state(:pending_approval)
                      .joins(collection: :reviewers)
                      .where('reviewers.user_id' => current_user),
      drafts: Work.with_state(:first_draft).where(depositor: current_user)
    )
  end
end
