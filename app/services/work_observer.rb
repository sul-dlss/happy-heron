# frozen_string_literal: true

# Actions that happen when something happens to a work
class WorkObserver
  def self.before_transition(work_version, transition)
    attributes = work_version.work.event_context.merge(event_type: transition.event)

    # a begin_deposit event is always preceded by a update_metadata event.
    # We don't want to log the description for that event twice, so clear it out.
    attributes = attributes.except(:description) if transition.event == :begin_deposit

    work_version.work.events.create(attributes)
  end

  def self.after_transition(work_version, transition)
    # nop
  end

  def self.after_begin_reserve(work_version, _transition)
    ReserveJob.perform_later(work_version)
  end

  def self.after_druid_assigned(work_version, transition)
    work = work_version.work
    work.update(doi: Doi.for(work.druid)) if transition.to_name == :purl_reserved && work.assign_doi?
    work_version.add_purl_to_citation
    work_version.add_doi_to_citation if work.doi
  end

  def self.after_depositing(work_version, _transition)
    work_version.update_attribute(:published_at, DateTime.now.utc) # rubocop:disable Rails/SkipsModelValidations
    DepositJob.perform_later(work_version)
  end

  def self.after_deposit_complete(work_version, _transition)
    work_version.switch_to_preserved_items!
    mailer = work_mailer(work_version)
    job = if work_version.work.collection.review_enabled?
      mailer.approved_email
    elsif work_version.version > 1
      mailer.new_version_deposited_email
    else
      mailer.deposited_email
    end
    job.deliver_later
    mailer.globus_deposited_email.deliver_later if work_version.globus_endpoint && Settings.notify_admin_list
  end

  def self.after_rejected(work_version, _transition)
    work_mailer(work_version).reject_email.deliver_later
  end

  def self.after_submit_for_review(work_version, _transition)
    collection = work_version.work.collection
    (collection.reviewed_by + collection.managed_by - [work_version.work.owner]).each do |recipient|
      next if collection.opted_out_of_email?(recipient, "submit_for_review")

      ReviewersMailer.with(user: recipient, work_version:).submitted_email.deliver_later
    end
    work_mailer(work_version).submitted_email.deliver_later
  end

  def self.after_decommission(work_version, _transition)
    WorksMailer.with(work_version:).decommission_owner_email.deliver_later
    collection = work_version.work.collection
    collection.managed_by.each do |recipient|
      next if collection.opted_out_of_email?(recipient, "item_deleted")

      WorksMailer.with(user: recipient, work_version:).decommission_manager_email.deliver_later
    end
  end

  def self.work_mailer(work_version)
    WorksMailer.with(user: work_version.work.owner, work_version:)
  end
  private_class_method :work_mailer
end
