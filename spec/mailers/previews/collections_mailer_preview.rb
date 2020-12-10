# typed: false
# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers
# Preview these emails at http://localhost:3000/rails/mailers/collections_mailer
class CollectionsMailerPreview < ActionMailer::Preview
  def invitation_to_deposit_email
    collection = Collection.first
    CollectionsMailer.with(user: collection.creator, collection: collection).invitation_to_deposit_email
  end
end
