# typed: false
# frozen_string_literal: true

# Handles CRUD for Collections
class CollectionsController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable
  verify_authorized except: %i[deposit_button delete_button]

  def new
    collection = Collection.new(creator: current_user)
    authorize! collection

    collection_version = CollectionVersion.new(collection: collection)
    @form = CreateCollectionForm.new(collection_version: collection_version, collection: collection)
    @form.prepopulate!
  end

  def create
    collection = Collection.new(creator: current_user)

    authorize! collection

    collection_version = CollectionVersion.new(collection: collection)
    @form = collection_form(collection_version)
    if @form.validate(collection_params) && @form.save
      after_save(collection: collection, collection_version: collection_version)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    collection = Collection.find(params[:id])
    collection_version = collection.head
    authorize! collection_version

    @form = collection_form(collection_version)
    @form.prepopulate!
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def update
    collection = Collection.find(params[:id])
    collection_version = collection.head
    clean_params = collection_params
    if collection_version.deposited?
      collection_version = create_new_version(collection_version)
      NewCollectionVersionParameterFilter.call(clean_params, collection.head)
    end

    authorize! collection_version
    point1 = CollectionChangeSet::PointInTime.new(collection)
    @form = collection_form(collection_version)
    if @form.validate(clean_params) && @form.save
      after_save(collection: collection, collection_version: collection_version,
                 context: { change_set: point1.diff(collection_version.collection) })
    else
      render :edit, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def show
    @collection = Collection.find(params[:id])
    authorize! @collection.head
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

  # We render this button lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the collection.
  def deposit_button
    collection = Collection.find(params[:id])
    render partial: 'collections/deposit_button', locals: { collection: collection }
  end

  # We render this button lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the collection.
  def delete_button
    collection = Collection.find(params[:id])
    render partial: 'collections/delete_button', locals: { collection: collection }
  end

  private

  # Create the next CollectionVersion for this Collection
  def create_new_version(previous_version)
    previous_version.dup.tap do |work_version|
      work_version.state = 'version_draft'
      work_version.version = previous_version.version + 1
    end
  end

  sig { params(collection_version: CollectionVersion, collection: Collection, context: Hash).void }
  def after_save(collection_version:, collection:, context: {})
    collection_version.collection.event_context = context.merge(user: current_user)
    collection_version.update_metadata!
    if deposit_button_pushed?
      collection_version.begin_deposit!
      redirect_to dashboard_path
    else
      redirect_to collection_path(collection)
    end
  end

  def collection_form(collection_version)
    if deposit_button_pushed?
      return CreateCollectionForm.new(collection_version: collection_version,
                                      collection: collection_version.collection)
    end

    DraftCollectionForm.new(collection_version: collection_version, collection: collection_version.collection)
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :access,
                                       :manager_sunets, :depositor_sunets,
                                       :review_enabled, :reviewer_sunets, :license_option,
                                       :required_license, :default_license,
                                       :email_when_participants_changed,
                                       :email_depositors_status_changed,
                                       :release_option, :release_duration,
                                       related_links_attributes: %i[_destroy id link_title url],
                                       contact_emails_attributes: %i[_destroy id email])
  end
end
