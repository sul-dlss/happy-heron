# frozen_string_literal: true

# Populates the nested keywords form
class KeywordsPopulator < ApplicationPopulator
  def call(form, args)
    # The fragment represents one row of the attached file data from the HTML form
    # find out if incoming file is already added.
    fragment = args.fetch(:fragment)
    item = existing_record(form:, id: fragment['id'])

    if fragment['_destroy'] == '1'
      form.keywords.delete(item)
      return skip!
    elsif fragment['label'].blank?
      return skip!
    end
    item || form.keywords.append(Keyword.new)
  end
end
