# frozen_string_literal: true

# Populates the nested related works form
class RelatedLinksPopulator < ApplicationPopulator
  # The fragment represents one row of the attached file data from the HTML form
  # find out if incoming file is already added.
  def call(form, args)
    fragment = args.fetch(:fragment)
    item = existing_record(form:, id: fragment['id'])

    if fragment['_destroy'] == '1'
      form.related_links.delete(item)
      return skip!
    elsif fragment['url'].blank?
      return skip!
    end
    item || form.related_links.append(RelatedLink.new)
  end
end
