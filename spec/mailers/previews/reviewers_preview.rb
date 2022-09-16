# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/reviewers
class ReviewersPreview < ActionMailer::Preview
  def submitted_email
    work = Work.first
    ReviewersMailer.with(user: work.depositor, work:).submitted_email
  end
end
