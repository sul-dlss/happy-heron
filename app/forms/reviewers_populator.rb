# frozen_string_literal: true

# Populates the nested collection reviwers
class ReviewersPopulator < CollectionContributorPopulator
  # Removes reviewers if review workflow is disabled
  def call(form, fragment:, as:, doc:, **) # rubocop:disable Naming/MethodParameterName
    return super if doc['review_enabled'] != 'false'

    item = existing_record(form: form, id: fragment['id'])
    # Remove reviewer
    form.public_send(as).delete(item) if item
    skip!
  end
end
