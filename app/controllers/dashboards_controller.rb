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
      approvals: Work.awaiting_review_by(current_user),
      in_progress: Work.with_state(:first_draft, :version_draft, :rejected)
                       .where(depositor: current_user),
      collection_managers_in_progress: current_user.manages_collections.with_state(:first_draft, :version_draft)
    )

    @presenter.work_stats = StatBuilder.build_stats if user_with_groups.administrator?
  end
end
