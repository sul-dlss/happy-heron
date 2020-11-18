# typed: strong
class Work
  sig { void }
  def submit_for_review!; end

  sig { returns(T::Boolean) }
  def first_draft?; end
end
