# typed: true
# frozen_string_literal: true

# Actions that happen when something happens to a collection
class CollectionObserver
  def self.collection_activity(work, _transition)
    work.collection.managers.reject { |manager| manager == work.depositor }.each do |user|
      mailer = CollectionsMailer.with(user: user, collection: work.collection, depositor: work.depositor)
      mailer.collection_activity.deliver_later
    end
  end

  # When an already published collection is updated
  def self.after_update_published(collection, _transition)
    depositors_added(collection)
    depositors_removed(collection)
    reviewers_added(collection)
  end

  def self.depositors_added(collection)
    change_set(collection).added_depositors.each do |depositor|
      CollectionsMailer.with(collection: collection, user: depositor)
                       .invitation_to_deposit_email.deliver_later
    end
  end
  private_class_method :depositors_added

  def self.depositors_removed(collection)
    return unless collection.email_depositors_status_changed?

    change_set(collection).removed_depositors.each do |depositor|
      CollectionsMailer.with(collection: collection, user: depositor)
                       .deposit_access_removed_email.deliver_later
    end
  end
  private_class_method :depositors_removed

  def self.reviewers_added(collection)
    change_set(collection).added_reviewers.each do |reviewer|
      CollectionsMailer.with(collection: collection, user: reviewer)
                       .review_access_granted_email.deliver_later
    end
  end
  private_class_method :reviewers_added

  def self.change_set(collection)
    collection.event_context.fetch(:change_set)
  end
  private_class_method :change_set
end
