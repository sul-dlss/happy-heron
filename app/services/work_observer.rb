# typed: true
# frozen_string_literal: true

# Actions that happen when something happens to a work
class WorkObserver
  def self.before_transition(work_version, transition)
    attributes = work_version.work.event_context.merge(event_type: transition.event)

    # an begin_deposit event is always preceded by a update_metadata event.
    # We don't want to log the description for that event twice, so clear it out.
    attributes = attributes.except(:description) if transition.event == :begin_deposit

    work_version.work.events.create(attributes)
  end

  def self.after_transition(work_version, transition)
    # nop
  end

  def self.after_begin_deposit(work_version, _transition)
    DepositJob.perform_later(work_version)
  end

  def self.after_work_rejected(work_version, _transition)
    work_mailer(work_version).reject_email.deliver_later
  end

  def self.after_deposit_complete(work_version, _transition)
    mailer = work_mailer(work_version)
    job = if work_version.work.collection.review_enabled?
            mailer.approved_email
          elsif work_version.version > 1
            mailer.new_version_deposited_email
          else
            mailer.deposited_email
          end
    job.deliver_later
  end

  def self.after_rejected(work_version, _transition)
    work_mailer(work_version).reject_email.deliver_later
  end

  def self.after_submit_for_review(work_version, _transition)
    collection = work_version.work.collection
    (collection.reviewed_by + collection.managed_by - [work_version.work.depositor]).each do |recipient|
      ReviewersMailer.with(user: recipient, work_version: work_version).submitted_email.deliver_later
    end
    work_mailer(work_version).submitted_email.deliver_later
  end

  def self.work_mailer(work_version)
    WorksMailer.with(user: work_version.work.depositor, work_version: work_version)
  end
  private_class_method :work_mailer
end
