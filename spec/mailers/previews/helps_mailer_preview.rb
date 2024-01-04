# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers
# Preview these emails at http://localhost:3000/rails/mailers/helps_mailer
class HelpsMailerPreview < ActionMailer::Preview
  def jira_email
    HelpsMailer.with(name: 'Barbara Seville',
                     email: 'razor@haircuts.it',
                     affiliation: 'Music School',
                     help_how: 'who should marry Rosina?',
                     why_contact: 'Don Basilio! – Cosa veggo!').jira_email
  end
end
