# frozen_string_literal: true

# Displays the list of collections and works to the user
class DashboardsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized except: :show

  def show
    return redirect_to root_path unless allowed_to?(:show?, :dashboard)

    authorize! :dashboard
    @presenter = build_presenter
    @page_content = PageContent.find_by(page: 'home')
  end

  private

  # rubocop:disable Metrics/AbcSize
  def build_presenter
    DashboardPresenter.new(
      just_signed_in: session.delete(:just_signed_in),
      collections: authorized_scope(Collection
                                      .includes('collection_versions')
                                      .order('collection_versions.name'), as: :deposit),
      approvals: WorkVersion.awaiting_review_by(current_user),
      in_progress: WorkVersion.with_state(:first_draft, :version_draft, :rejected, :purl_reserved)
                     .joins(:work)
                     .where('works.owner' => current_user),
      collection_managers_in_progress: CollectionVersion.with_state(:first_draft, :version_draft)
                                         .joins(:collection).left_outer_joins(collection: :managed_by)
                                         .where('managers.user_id' => current_user)
                                         .order('collection_versions.updated_at desc')
    )
  end
  # rubocop:enable Metrics/AbcSize
end
