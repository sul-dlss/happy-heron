# frozen_string_literal: true

# Sends email notifications about first_draft_collections
class FirstDraftCollectionsMailer < ApplicationMailer
  NEW_COLLECTION_SUBJECT = 'A new collection has been created'

  def first_draft_created
    @collection_version = params[:collection_version]
    @creator = @collection_version.collection.creator

    mail(to: Settings.notifications.admin_email, subject: NEW_COLLECTION_SUBJECT)
  end
end
