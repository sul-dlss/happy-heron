# typed: true
# frozen_string_literal: true

# Actions that happen when something happens to a collection
class CollectionObserver
  def self.collection_activity(work_version, _transition)
    depositor = work_version.work.depositor
    collection = work_version.work.collection
    collection.managed_by.reject { |manager| manager == depositor }.each do |user|
      mailer = CollectionsMailer.with(user: user, collection_version: collection.head, depositor: depositor)
      mailer.collection_activity.deliver_later
    end
  end

  # When an already published collection is updated
  def self.after_update_published(collection, change_set:, user:)
    event_params = { user: user, event_type: 'settings_updated' }
    event_params[:description] = change_set.participant_change_description if change_set.participants_changed?
    collection.events.create(event_params)
    collection_version = collection.head
    managers_added(collection_version, change_set)
    managers_removed(collection_version, change_set)
    depositors_added(collection_version, change_set)
    depositors_removed(collection_version, change_set) if collection.email_depositors_status_changed?
    reviewers_added(collection_version, change_set)
    reviewers_removed(collection_version, change_set)
    send_participant_change_emails(collection, change_set)
  end

  def self.depositors_added(collection_version, change_set)
    change_set.added_depositors.each do |depositor|
      CollectionsMailer.with(collection_version: collection_version, user: depositor)
                       .invitation_to_deposit_email.deliver_later
    end
  end
  private_class_method :depositors_added

  def self.managers_added(collection_version, change_set)
    change_set.added_managers.each do |manager|
      CollectionsMailer.with(collection_version: collection_version, user: manager)
                       .manage_access_granted_email.deliver_later
    end
  end
  private_class_method :managers_added

  def self.managers_removed(collection_version, change_set)
    change_set.removed_managers.each do |manager|
      CollectionsMailer.with(collection_version: collection_version, user: manager)
                       .manage_access_removed_email.deliver_later
    end
  end
  private_class_method :managers_removed

  def self.depositors_removed(collection_version, change_set)
    change_set.removed_depositors.each do |depositor|
      CollectionsMailer.with(collection_version: collection_version, user: depositor)
                       .deposit_access_removed_email.deliver_later
    end
  end
  private_class_method :depositors_removed

  def self.reviewers_added(collection_version, change_set)
    change_set.added_reviewers.each do |reviewer|
      CollectionsMailer.with(collection_version: collection_version, user: reviewer)
                       .review_access_granted_email.deliver_later
    end
  end
  private_class_method :reviewers_added

  def self.reviewers_removed(collection_version, change_set)
    change_set.removed_reviewers.each do |reviewer|
      CollectionsMailer.with(collection_version: collection_version, user: reviewer)
                       .review_access_removed_email.deliver_later
    end
  end
  private_class_method :reviewers_removed

  def self.send_participant_change_emails(collection, change_set)
    return unless collection.email_when_participants_changed? && change_set.participants_changed?

    (collection.managed_by + collection.reviewed_by).each do |user|
      CollectionsMailer.with(collection_version: collection.head, user: user)
                       .participants_changed_email.deliver_later
    end
  end
  private_class_method :send_participant_change_emails
end
