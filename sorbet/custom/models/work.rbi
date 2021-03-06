# typed: strong
class Work
  sig { void }
  def submit_for_review!; end

  sig { void }
  def update_metadata!; end

  sig { void }
  def begin_deposit!; end

  sig { void }
  def reject!; end

  sig { void }
  def deposit_complete!; end

  sig { returns(T::Boolean) }
  def deposited?; end

  sig { returns(T::Boolean) }
  def first_draft?; end

  sig { params(args: Symbol).returns(ActiveRecord::Relation) }
  def self.with_state(*args); end
end
