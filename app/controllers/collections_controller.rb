# typed: false
# frozen_string_literal: true

# Handles CRUD for Collections
class CollectionsController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable
  verify_authorized

  def new
    collection = Collection.new(creator: current_user)
    authorize! collection

    @form = CollectionForm.new(collection)
    @form.prepopulate!
  end

  def edit
    collection = Collection.find(params[:id])
    authorize! collection

    @form = CollectionForm.new(collection)
    @form.prepopulate!
  end

  def create
    collection = Collection.new(creator: current_user)
    authorize! collection

    @form = collection_form(collection)
    if @form.validate(collection_params) && @form.save
      # for the first time creation of a collection, send notifications to all depositors
      send_depositor_notifications(collection, collection.depositors)
      after_save(collection)
    else
      # Send form errors to client in JSON format to be parsed and rendered there
      render 'errors', status: :bad_request
    end
  end

  def update
    collection = Collection.find(params[:id])
    authorize! collection
    previous_depositors = collection.depositors.to_a # this .to_a ensures we have a frozen copy of the depositors
    @form = collection_form(collection)
    if @form.validate(collection_params) && @form.save
      collection.update_metadata!
      # for an update of an existing collection, we will send notifications to only newly added depositors
      send_depositor_notifications(collection, collection.depositors - previous_depositors)
      after_save(collection)
    else
      # Send form errors to client in JSON format to be parsed and rendered there
      render 'errors', status: :bad_request
    end
  end

  def show
    @collection = Collection.find(params[:id])
    authorize! @collection
  end

  def destroy
    collection = Collection.find(params[:id])
    authorize! collection

    collection.destroy

    redirect_to dashboard_path
  end

  private

  sig { params(collection: Collection).void }
  def after_save(collection)
    collection.event_context = { user: current_user }
    if deposit_button_pushed?
      collection.begin_deposit!
      redirect_to dashboard_path
    else
      collection.update_metadata!
      redirect_to collection_path(collection)
    end
  end

  def send_depositor_notifications(collection, depositors)
    # we only send notifications if we press submit deposit
    # (i.e. not saving as a draft) OR if this >v1 of the collection
    # this allows us to save/update drafts of a brand new collection *without* sending notifications
    # until the user deposits for the first time, and also allows us to send notifications for
    # newly added depositors on *any* save (draft or deposit) of future versions
    return unless deposit_button_pushed? || collection.version_draft?

    depositors.each do |depositor|
      CollectionsMailer.with(collection: collection, user: depositor)
                       .invitation_to_deposit_email.deliver_later
    end
  end

  def collection_form(collection)
    return CollectionForm.new(collection) if deposit_button_pushed?

    DraftCollectionForm.new(collection)
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :contact_email,
                                       :access, :manager_sunets, :depositor_sunets,
                                       :review_enabled, :reviewer_sunets,
                                       :email_when_participants_changed,
                                       :email_depositors_status_changed,
                                       related_links_attributes: %i[_destroy id link_title url])
  end
end
