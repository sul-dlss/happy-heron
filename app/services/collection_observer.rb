# frozen_string_literal: true

# Actions that happen when something happens to a collection
class CollectionObserver
  def self.first_draft_created(work_version, _transition)
    collection_managers_excluding_owner(work_version).each do |user|
      next if work_version.work.collection.opted_out_of_email?(user, 'new_item')

      mailer_with_owner(user:, work_version:).first_draft_created.deliver_later
    end
  end

  def self.item_deposited(work_version, _transition)
    collection_managers_excluding_owner(work_version).each do |user|
      next if work_version.work.collection.opted_out_of_email?(user, 'new_item')

      mailer_with_owner(user:, work_version:).item_deposited.deliver_later
    end
  end

  def self.version_draft_created(work_version, _transition)
    collection_managers_excluding_owner(work_version).each do |user|
      next if work_version.work.collection.opted_out_of_email?(user, 'new_item')

      mailer_with_owner(user:, work_version:).version_draft_created.deliver_later
    end
  end

  # When an already published collection is updated
  def self.settings_updated(collection, change_set:, user:, form:)
    create_settings_updated_event(collection:, change_set:, form:, user:)

    collection_version = collection.head
    managers_added(collection_version, change_set)
    managers_removed(collection_version, change_set)
    depositors_added(collection_version, change_set)
    depositors_removed(collection_version, change_set) if collection.email_depositors_status_changed?
    reviewers_added(collection_version, change_set)
    reviewers_removed(collection_version, change_set)
    send_participant_change_emails(collection, change_set)
    fix_state(collection) unless collection.review_enabled
  end

  def self.after_decommission(collection_version, _transition)
    collection_version.collection.managed_by.each do |recipient|
      next if collection_version.collection.opted_out_of_email?(recipient, 'decommissioned')

      CollectionsMailer.with(user: recipient, collection_version:).decommission_manager_email.deliver_later
    end
  end

  def self.create_settings_updated_event(collection:, change_set:, form:, user:)
    event_params = { user:, event_type: 'settings_updated' }.tap do |params|
      description = CollectionEventDescriptionBuilder.build(change_set:, form:)
      params[:description] = description if description.present?
    end
    collection.events.create(event_params)
  end
  private_class_method :create_settings_updated_event

  def self.collection_managers_excluding_owner(work_version)
    owner = work_version.work.owner
    collection = work_version.work.collection
    collection.managed_by.reject { |manager| manager == owner }
  end
  private_class_method :collection_managers_excluding_owner

  def self.mailer_with_owner(user:, work_version:)
    work = work_version.work
    owner = work.owner
    collection_version = work.collection.head
    CollectionsMailer.with(user:, collection_version:, owner:, work:)
  end
  private_class_method :mailer_with_owner

  def self.depositors_added(collection_version, change_set)
    change_set.added_depositors.each do |depositor|
      CollectionsMailer.with(collection_version:, user: depositor)
                       .invitation_to_deposit_email.deliver_later
    end
  end
  private_class_method :depositors_added

  def self.managers_added(collection_version, change_set)
    change_set.added_managers.each do |manager|
      CollectionsMailer.with(collection_version:, user: manager)
                       .manage_access_granted_email.deliver_later
    end
  end
  private_class_method :managers_added

  def self.managers_removed(collection_version, change_set)
    change_set.removed_managers.each do |manager|
      CollectionsMailer.with(collection_version:, user: manager)
                       .manage_access_removed_email.deliver_later
    end
  end
  private_class_method :managers_removed

  def self.depositors_removed(collection_version, change_set)
    change_set.removed_depositors.each do |depositor|
      CollectionsMailer.with(collection_version:, user: depositor)
                       .deposit_access_removed_email.deliver_later
    end
  end
  private_class_method :depositors_removed

  def self.reviewers_added(collection_version, change_set)
    change_set.added_reviewers.each do |reviewer|
      CollectionsMailer.with(collection_version:, user: reviewer)
                       .review_access_granted_email.deliver_later
    end
  end
  private_class_method :reviewers_added

  def self.reviewers_removed(collection_version, change_set)
    change_set.removed_reviewers.each do |reviewer|
      CollectionsMailer.with(collection_version:, user: reviewer)
                       .review_access_removed_email.deliver_later
    end
  end
  private_class_method :reviewers_removed

  def self.send_participant_change_emails(collection, change_set)
    return unless collection.email_when_participants_changed? && change_set.participants_changed?

    (collection.managed_by + collection.reviewed_by).uniq.each do |user|
      next if collection.opted_out_of_email?(user, 'participant_changed')

      # Don't send if the user is the only changed participant.
      unless change_set.changed_participants == [user]
        CollectionsMailer.with(collection_version: collection.head, user:)
                         .participants_changed_email.deliver_later
      end
    end
  end
  private_class_method :send_participant_change_emails

  def self.fix_state(collection)
    collection.works.joins(:head).where("state in ('pending_approval', 'rejected')").each do |work|
      work.head.no_review_workflow!
    end
  end
  private_class_method :fix_state
end
