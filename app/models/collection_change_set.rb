# typed: false
# frozen_string_literal: true

# Represents the difference in a Collection before and after an update.
class CollectionChangeSet
  extend T::Sig

  sig { params(point1: PointInTime, point2: PointInTime).void }
  def initialize(point1, point2)
    @point1 = point1
    @point2 = point2
  end

  sig { returns(T::Array[User]) }
  def added_managers
    point2.managers - point1.managers
  end

  sig { returns(T::Array[User]) }
  def added_depositors
    point2.depositors - point1.depositors
  end

  sig { returns(T::Array[User]) }
  def added_reviewers
    point2.reviewers - point1.reviewers
  end

  sig { returns(T::Array[User]) }
  def removed_depositors
    point1.depositors - point2.depositors
  end

  sig { returns(T::Array[User]) }
  def removed_managers
    point1.managers - point2.managers
  end

  sig { returns(T::Array[User]) }
  def removed_reviewers
    point1.reviewers - point2.reviewers
  end

  sig { returns(T::Boolean) }
  def participants_changed?
    added_managers.present? || added_depositors.present? || added_reviewers.present? ||
      removed_managers.present? || removed_depositors.present? || removed_reviewers.present?
  end

  sig { returns(String) }
  def participant_change_description
    %i[added_managers added_depositors added_reviewers
       removed_managers removed_depositors removed_reviewers].map do |field_name|
      field_changes = send(field_name)
      next if field_changes.blank?

      "#{field_name.to_s.humanize}: #{field_changes.map(&:sunetid).join(', ')}"
    end.compact.join("\n")
  end

  sig { returns(PointInTime) }
  attr_reader :point1, :point2

  # Represents a collection at a fixed point in time
  class PointInTime
    extend T::Sig

    sig { params(collection: Collection).void }
    def initialize(collection)
      # Need to read these associations and cache them because the
      # underlying data in the database is mutable
      @depositors = T.let(collection.depositors.to_a, T::Array[User])
      @reviewers = T.let(collection.reviewed_by.to_a, T::Array[User])
      @managers = T.let(collection.managers.to_a, T::Array[User])
    end

    sig { returns(T::Array[User]) }
    attr_reader :depositors, :reviewers, :managers

    sig { params(collection: Collection).returns(CollectionChangeSet) }
    def diff(collection)
      CollectionChangeSet.new(self, PointInTime.new(collection))
    end
  end
end
