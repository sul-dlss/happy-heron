# typed: false
# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers
# Preview these emails at http://localhost:3000/rails/mailers/collections_mailer
class CollectionsMailerPreview < ActionMailer::Preview
  delegate :invitation_to_deposit_email, :deposit_access_removed_email,
           :review_access_granted_email, :participants_changed_email,
           to: :mailer_with_collection

  private

  def mailer_with_collection
    collection = Collection.first
    CollectionsMailer.with(user: collection.creator, collection: collection)
  end
end
