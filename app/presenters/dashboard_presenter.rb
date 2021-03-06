# typed: strict
# frozen_string_literal: true

# The page model for the dashboard
class DashboardPresenter
  extend T::Sig

  sig do
    params(just_signed_in: T.nilable(T::Boolean),
           in_progress: ActiveRecord::Relation,
           approvals: ActiveRecord::Relation,
           collections: ActiveRecord::Relation,
           collection_managers_in_progress: ActiveRecord::Relation).void
  end
  def initialize(just_signed_in:, in_progress:, approvals:, collections:, collection_managers_in_progress:)
    @just_signed_in = just_signed_in
    @in_progress = in_progress
    @approvals = approvals
    @collections = collections
    @collection_managers_in_progress = collection_managers_in_progress
  end

  sig { returns(ActiveRecord::Relation) }
  attr_reader :in_progress

  sig { returns(ActiveRecord::Relation) }
  attr_reader :collection_managers_in_progress

  sig { returns(ActiveRecord::Relation) }
  attr_reader :approvals

  sig { returns(ActiveRecord::Relation) }
  attr_reader :collections

  sig { returns(T.nilable(T::Hash[Collection, T::Hash[String, Integer]])) }
  attr_accessor :work_stats

  sig { returns(T.nilable(T::Boolean)) }
  def show_popup?
    @just_signed_in && in_progress.any?
  end
end
