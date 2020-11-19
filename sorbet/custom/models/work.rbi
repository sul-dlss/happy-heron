# typed: strong
class Work
  sig { void }
  def submit_for_review!; end

  sig { void }
  def new_version!; end

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
end
