# frozen_string_literal: true

# Represents the difference in a Collection before and after an update.
class CollectionChangeSet
  def initialize(point1, point2)
    @point1 = point1
    @point2 = point2
  end

  def added_managers
    point2.managers - point1.managers
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

  def removed_managers
    point1.managers - point2.managers
  end

  def removed_reviewers
    point1.reviewers - point2.reviewers
  end

  def participants_changed?
    changed_participants.present?
  end

  def changed_participants
    (added_managers +
      added_depositors +
      added_reviewers +
      removed_managers +
      removed_depositors +
      removed_reviewers).uniq
  end

  def email_depositors_status_changed_changed?
    point1.email_depositors_status_changed != point2.email_depositors_status_changed
  end

  def email_when_participants_changed_changed?
    point1.email_when_participants_changed != point2.email_when_participants_changed
  end

  def review_enabled_changed?
    point1.review_enabled != point2.review_enabled
  end

  def reviewers_changed?
    removed_reviewers.present? || added_reviewers.present?
  end

  def participant_change_description
    %i[added_managers added_depositors added_reviewers
      removed_managers removed_depositors removed_reviewers].filter_map do |field_name|
      field_changes = send(field_name)
      next if field_changes.blank?

      "#{field_name.to_s.humanize}: #{field_changes.map(&:sunetid).join(", ")}"
    end.join("\n")
  end

  attr_reader :point1, :point2

  # Represents a collection at a fixed point in time
  class PointInTime
    def initialize(collection)
      # Need to read these associations and cache them because the
      # underlying data in the database is mutable
      @depositors = collection.depositors.to_a
      @reviewers = collection.reviewed_by.to_a
      @managers = collection.managed_by.to_a
      @email_when_participants_changed = collection.email_when_participants_changed
      @email_depositors_status_changed = collection.email_depositors_status_changed
      @review_enabled = collection.review_enabled
    end

    attr_reader :depositors, :reviewers, :managers, :email_when_participants_changed, :email_depositors_status_changed,
      :review_enabled

    def diff(collection)
      CollectionChangeSet.new(self, PointInTime.new(collection))
    end
  end
end
