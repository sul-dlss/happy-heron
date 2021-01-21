# typed: strict
# frozen_string_literal: true

# The page model for the dashboard
class DashboardPresenter
  extend T::Sig

  sig do
    params(in_progress: ActiveRecord::Relation,
           approvals: ActiveRecord::Relation,
           collections: ActiveRecord::Relation).void
  end
  def initialize(in_progress:, approvals:, collections:)
    @in_progress = in_progress
    @approvals = approvals
    @collections = collections
  end

  sig { returns(ActiveRecord::Relation) }
  attr_reader :in_progress

  sig { returns(ActiveRecord::Relation) }
  attr_reader :approvals

  sig { returns(ActiveRecord::Relation) }
  attr_reader :collections

  sig { returns(T.nilable(T::Hash[Collection, T::Hash[String, Integer]])) }
  attr_accessor :work_stats
end
