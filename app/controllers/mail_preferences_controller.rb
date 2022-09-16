# frozen_string_literal: true

# Edite the user's email notification preferences
class MailPreferencesController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def edit
    @collection = Collection.find(params[:collection_id])
    authorize! @collection, to: :manage_email_preferences?
    @preferences = @collection.mail_preferences_for_user(current_user)
  end

  def update
    @collection = Collection.find(params[:collection_id])
    authorize! @collection, to: :manage_email_preferences?
    MailPreference.transaction do
      @collection.mail_preferences_for_user(current_user).each do |preference|
        preference.update(wanted: !params[preference.email].nil?)
      end
    end
    redirect_to profile_path
  end
end
