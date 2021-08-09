# frozen_string_literal: true

# Populates the nested related works form
class RelatedWorksPopulator < ApplicationPopulator
  # The fragment represents one row of the attached file data from the HTML form
  # find out if incoming file is already added.
  def call(form, fragment:, **)
    item = existing_record(form: form, id: fragment['id'])

    if fragment['_destroy'] == '1'
      form.related_works.delete(item)
      return skip!
    elsif fragment['citation'].blank?
      return skip!
    end
    item || form.related_works.append(RelatedWork.new)
  end
end
