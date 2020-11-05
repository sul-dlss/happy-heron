# typed: strict
# frozen_string_literal: true

# The page model for the dashboard
class DashboardPresenter
  extend T::Sig

  sig { params(drafts: ActiveRecord::Relation, collections: ActiveRecord::Relation).void }
  def initialize(drafts:, collections:)
    @drafts = drafts
    @collections = collections
  end

  sig { returns(ActiveRecord::Relation) }
  attr_reader :drafts

  sig { returns(ActiveRecord::Relation) }
  attr_reader :collections
end
