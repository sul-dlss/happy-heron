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

    add_breadcrumb 'Create', ''
  end

  def edit
    collection = Collection.find(params[:id])
    authorize! collection

    @form = CollectionForm.new(collection)
    @form.prepopulate!

    add_breadcrumb collection.name, collection_path(collection)
    add_breadcrumb 'Edit', ''
  end

  def create
    collection = Collection.new(creator: current_user)
    authorize! collection

    @form = collection_form(collection)
    if @form.validate(collection_params) && @form.save
      after_save(collection)
    else
      # Send form errors to client in JSON format to be parsed and rendered there
      render 'errors', status: :bad_request
    end
  end

  def update
    collection = Collection.find(params[:id])
    authorize! collection
    point1 = CollectionChangeSet::PointInTime.new(collection)
    @form = collection_form(collection)
    if @form.validate(collection_params) && @form.save
      after_save(collection, context: { change_set: point1.diff(collection) })
    else
      # Send form errors to client in JSON format to be parsed and rendered there
      render 'errors', status: :bad_request
    end
  end

  def show
    @collection = Collection.find(params[:id])
    authorize! @collection

    add_breadcrumb @collection.name, ''
  end

  def destroy
    collection = Collection.find(params[:id])
    authorize! collection

    collection.destroy

    redirect_to dashboard_path
  end

  private

  sig { params(collection: Collection, context: Hash).void }
  def after_save(collection, context: {})
    collection.event_context = context.merge(user: current_user)
    collection.update_metadata!
    if deposit_button_pushed?
      collection.begin_deposit!
      redirect_to dashboard_path
    else
      redirect_to collection_path(collection)
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
                                       :release_option, :release_duration,
                                       'release_date(1i)', 'release_date(2i)', 'release_date(3i)',
                                       related_links_attributes: %i[_destroy id link_title url])
  end
end
