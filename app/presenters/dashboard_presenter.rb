# frozen_string_literal: true

# The page model for the dashboard
class DashboardPresenter
  def initialize(just_signed_in:, in_progress:, approvals:, collections:,
                 collection_managers_in_progress:)
    @just_signed_in = just_signed_in
    @in_progress = in_progress
    @approvals = approvals
    @collections = collections
    @collection_managers_in_progress = collection_managers_in_progress
  end

  attr_reader :in_progress

  attr_reader :collection_managers_in_progress

  attr_reader :approvals

  attr_reader :collections

  def show_popup?
    @just_signed_in && (in_progress_works? || in_progress_collections?)
  end

  def in_progress_works?
    @in_progress.any? { |deposit| !deposit.purl_reserved? }
  end

  def in_progress_collections?
    !@collection_managers_in_progress.size.zero?
  end
end
