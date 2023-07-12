# frozen_string_literal: true

# Populates the nested affiliations form
class AffiliationsPopulator < ApplicationPopulator
  def call(form, args)
    # The fragment represents one row of the affiliations data from the HTML form
    # find out if incoming affiliation is already added.
    fragment = args.fetch(:fragment)
    item = existing_record(form:, id: fragment["id"])

    if fragment["_destroy"] == "1"
      form.affiliations.delete(item)
      return skip!
    elsif fragment["label"].blank? && fragment["department"].blank?
      return skip!
    end
    item || form.affiliations.append(Affiliation.new)
  end
end
