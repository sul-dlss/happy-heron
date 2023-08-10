# frozen_string_literal: true

# Handles CRUD for Collections
class CollectionsController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable
  verify_authorized except: %i[admin dashboard delete_button deposit_button edit_link]

  def show
    @collection = Collection.find(params[:id])
    authorize! @collection
  end

  def edit
    collection = Collection.find(params[:id])
    authorize! collection

    # if we end up on the edit page for a first draft (non-deposited collection), redirect to first draft edit page
    redirect_to edit_first_draft_collection_path(collection) if collection.head.first_draft?

    @form = CollectionSettingsForm.new(collection)

    @form.prepopulate!
  end

  def update
    collection = Collection.find(params[:id])
    authorize! collection
    point1 = CollectionChangeSet::PointInTime.new(collection)
    @form = CollectionSettingsForm.new(collection)
    if @form.validate(update_params) && @form.save
      CollectionObserver.settings_updated(collection, change_set: point1.diff(collection), user: current_user,
        form: @form)

      redirect_to collection_path(collection)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    collection = Collection.find(params[:id])
    authorize! collection

    collection.transaction do
      collection.update(head: nil)
      collection.destroy
    end

    redirect_to dashboard_path
  end

  # We render this partial lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the collection.
  def dashboard
    collection = Collection.find(params[:id])
    render partial: "collections/dashboard", locals: {collection:}
  end

  # We render this button lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the collection.
  def deposit_button
    collection = Collection.find(params[:id])
    render partial: "collections/deposit_button", locals: {collection:}
  end

  # We render this button lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the collection.
  def delete_button
    collection = Collection.find(params[:id])
    render partial: "collections/delete_button", locals: {collection:}
  end

  # We render this link lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the collection.
  # NOTE, the "ref" parameter is used to create the anchor as well as the dom_id for the turbo-frame
  # so when you link to this method ensure the dom_id or the containing frame matches the target anchor.
  def edit_link
    collection = Collection.find(params[:id])
    label = params.fetch(:label) { "Edit #{collection.head.name}" }
    render partial: "edit_link", locals: {
      collection:,
      label:,
      anchor: params[:ref]
    }
  end

  def admin
    @collection = Collection.find(params[:id])
  end

  private

  def update_params
    params.require(:collection).permit(:access, :doi_option,
      :review_enabled, :license_option,
      :required_license, :default_license,
      :custom_rights_statement_option, :provided_custom_rights_statement,
      :custom_rights_statement_custom_instructions,
      :email_when_participants_changed,
      :email_depositors_status_changed,
      :release_option, :release_duration,
      managed_by_attributes: %i[_destroy id sunetid],
      reviewed_by_attributes: %i[_destroy id sunetid],
      depositors_attributes: %i[_destroy id sunetid])
  end
end
