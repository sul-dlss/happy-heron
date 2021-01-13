# typed: true
# frozen_string_literal: true

# Populates the nested contact email form
class ContactEmailsPopulator < ApplicationPopulator
  # The fragment represents one row of the attached file data from the HTML form
  # find out if incoming file is already added.
  def call(form, fragment:, **)
    item = existing_record(form: form, id: fragment['id'])

    if fragment['_destroy'] == '1'
      form.contact_email.delete(item)
      return skip!
    elsif fragment['url'].blank?
      return skip!
    end
    item || form.contact_email.append(ContactEmail.new)
  end
end
