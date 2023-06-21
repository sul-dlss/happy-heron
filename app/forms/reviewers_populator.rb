# frozen_string_literal: true

# Populates the nested collection reviwers
class ReviewersPopulator < CollectionContributorPopulator
  # Removes reviewers if review workflow is disabled
  def call(form, args)
    doc = args.fetch(:doc)
    return super if doc["review_enabled"] != "false"

    fragment = args.fetch(:fragment)
    item = existing_record(form:, id: fragment["id"])
    # Remove reviewer
    as = args.fetch(:as)
    form.public_send(as).delete(item) if item
    skip!
  end
end
