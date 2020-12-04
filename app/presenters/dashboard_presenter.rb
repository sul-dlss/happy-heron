# typed: strict
# frozen_string_literal: true

# The page model for the dashboard
class DashboardPresenter
  extend T::Sig

  sig do
    params(drafts: ActiveRecord::Relation,
           approvals: ActiveRecord::Relation,
           collections: ActiveRecord::Relation).void
  end
  def initialize(drafts:, approvals:, collections:)
    @drafts = drafts
    @approvals = approvals
    @collections = collections
  end

  sig { returns(ActiveRecord::Relation) }
  attr_reader :drafts

  sig { returns(ActiveRecord::Relation) }
  attr_reader :approvals

  sig { returns(ActiveRecord::Relation) }
  attr_reader :collections

  sig { returns(T.nilable(T::Hash[Collection, T::Hash[String, Integer]])) }
  attr_accessor :work_stats
end
