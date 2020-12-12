# typed: false
# frozen_string_literal: true

# Represents the difference in a Collection before and after an update.
class CollectionChangeSet
  def self.from(collection)
    PointInTime.new(collection)
  end

  def initialize(point1, point2)
    @point1 = point1
    @point2 = point2
  end

  def added_depositors
    point2.depositors - point1.depositors
  end

  def added_reviewers
    point2.reviewers - point1.reviewers
  end

  def removed_depositors
    point1.depositors - point2.depositors
  end

  attr_reader :point1, :point2

  # Represents a collection at a fixed point in time
  class PointInTime
    def initialize(collection)
      # Need to read these associations and cache them because the
      # underlying data in the database is mutable
      @depositors = collection.depositors.to_a
      @reviewers = collection.reviewers.to_a
    end

    attr_reader :depositors, :reviewers

    def to(collection)
      CollectionChangeSet.new(self, PointInTime.new(collection))
    end
  end
end
