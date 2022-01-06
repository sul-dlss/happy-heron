# frozen_string_literal: true

# Populates the nested collection contributors
class CollectionContributorPopulator < ApplicationPopulator
  # The fragment represents one contributor from the HTML form
  # find out if incoming contributor is already added.
  def call(form, args) # rubocop:disable Metrics/AbcSize
    fragment = args.fetch(:fragment)
    as = args.fetch(:as)

    item = existing_record(form: form, id: fragment['id'])
    if fragment['_destroy'] == '1'
      # Remove contributor
      form.public_send(as).delete(item) if item
      return skip!
    end

    # Prevent duplicates
    collection = args.fetch(:collection)
    return skip! if collection.map(&:sunetid).include?(fragment['sunetid'])
    return item if item

    # This must be "or create" because we could end up with an email conflict if
    # the user is added in two fields simultaneously.
    user = User.find_or_create_by(email: "#{fragment['sunetid']}@stanford.edu")
    form.public_send(as).append(user)
  end
end
