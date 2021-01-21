# typed: false
# frozen_string_literal: true

# Displays the list of collections and works to the user
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
      in_progress: Work.with_state(:first_draft, :version_draft, :rejected)
                       .where(depositor: current_user)
    )

    @presenter.work_stats = StatBuilder.build_stats if user_with_groups.administrator?
  end
end
