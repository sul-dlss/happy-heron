# typed: true
# frozen_string_literal: true

# Populates the nested contact email form
class ContactEmailsPopulator < ApplicationPopulator
  # The fragment represents one row of the attached file data from the HTML form
  def call(form, fragment:, **)
    item = existing_record(form: form, id: fragment['id'])

    if fragment['_destroy'] == '1'
      form.contact_emails.delete(item)
      return skip!
    elsif fragment['email'].blank?
      return skip!
    end
    item || form.contact_emails.append(ContactEmail.new)
  end
end
