# typed: false
# frozen_string_literal: true

# Displays the list of collections and works to the user
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  # rubocop:disable Metrics/AbcSize
  def show
    authorize! :dashboard
    @presenter = DashboardPresenter.new(
      collections: authorized_scope(Collection.all, as: :deposit),
      approvals: Work.with_state(:pending_approval)
                     .joins(collection: :reviewed_by)
                     .where('reviewers.user_id' => current_user),
      in_progress: Work.with_state(:first_draft, :version_draft, :rejected)
                       .where(depositor: current_user),
      collection_managers_in_progress: Collection.with_state(:first_draft, :version_draft)
                                                 .joins(:managers).where("managers.user_id = #{current_user.id}")
    )

    @presenter.work_stats = StatBuilder.build_stats if user_with_groups.administrator?
  end
  # rubocop:enable Metrics/AbcSize
end
