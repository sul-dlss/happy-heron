# typed: strong
# This is an autogenerated file for Rails' mailers.
# Please rerun bundle exec rake rails_rbi:mailers to regenerate.
class WorksMailer
  sig { returns(ActionMailer::MessageDelivery) }
  def self.approved_email; end

  sig { returns(ActionMailer::MessageDelivery) }
  def self.deposited_email; end

  sig { returns(ActionMailer::MessageDelivery) }
  def self.first_draft_reminder_email; end

  sig { returns(ActionMailer::MessageDelivery) }
  def self.new_version_deposited_email; end

  sig { returns(ActionMailer::MessageDelivery) }
  def self.new_version_reminder_email; end

  sig { returns(ActionMailer::MessageDelivery) }
  def self.reject_email; end

  sig { returns(ActionMailer::MessageDelivery) }
  def self.submitted_email; end
end
