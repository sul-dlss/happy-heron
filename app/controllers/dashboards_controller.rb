# typed: false
# frozen_string_literal: true

# Displays the list of collections and works to the user
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def show
    authorize! :dashboard
    @presenter = build_presenter

    @presenter.work_stats = StatBuilder.build_stats if user_with_groups.administrator?
  end

  private

  def build_presenter
    DashboardPresenter.new(
      just_signed_in: session.delete(:just_signed_in),
      collections: authorized_scope(Collection.all, as: :deposit),
      approvals: WorkVersion.awaiting_review_by(current_user),
      in_progress: WorkVersion.with_state(:first_draft, :version_draft, :rejected)
                     .joins(:work)
                     .where('works.depositor' => current_user),
      collection_managers_in_progress: CollectionVersion.with_state(:first_draft, :version_draft)
                                         .joins(:collection).left_outer_joins(collection: :managed_by)
                                         .where('managers.user_id' => current_user)
    )
  end
end
