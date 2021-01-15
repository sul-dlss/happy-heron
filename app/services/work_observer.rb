# typed: false
# frozen_string_literal: true

# Actions that happen when something happens to a work
class WorkObserver
  def self.before_transition(work, transition)
    work.events.build(work.event_context.merge(event_type: transition.event))
  end

  def self.after_transition(work, transition)
    BroadcastWorkChange.call(work: work, state: transition.to_name)
  end

  def self.after_begin_deposit(work, _transition)
    DepositJob.perform_later(work)
  end

  def self.after_work_rejected(work, _transition)
    work_mailer(work).reject_email.deliver_later
  end

  def self.after_deposit_complete(work, _transition)
    mailer = work_mailer(work)
    job = if work.collection.review_enabled?
            mailer.approved_email
          elsif work.version > 1
            mailer.new_version_deposited_email
          else
            mailer.deposited_email
          end
    job.deliver_later
  end

  def self.after_rejected(work, _transition)
    work_mailer(work).reject_email.deliver_later
  end

  # rubocop:disable Metrics/AbcSize
  def self.after_submit_for_review(work, _transition)
    work_mailer(work).reject_email.deliver_later
    (work.collection.reviewers + work.collection.managers - [work.depositor]).each do |recipient|
      ReviewersMailer.with(user: recipient, work: work).submitted_email.deliver_later
    end
    work_mailer(work).submitted_email.deliver_later
  end
  # rubocop:enable Metrics/AbcSize

  def self.work_mailer(work)
    WorksMailer.with(user: work.depositor, work: work)
  end
  private_class_method :work_mailer
end
