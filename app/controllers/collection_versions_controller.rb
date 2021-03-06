# typed: false
# frozen_string_literal: true

# The endpoint for CRUD about a CollectionVersions
class CollectionVersionsController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable, except: [:destroy]
  verify_authorized

  def show
    @collection_version = CollectionVersion.find(params[:id])
    authorize! @collection_version
  end

  # Revert the work to the previously deposited version.
  def destroy
    version = CollectionVersion.find(params[:id])
    collection = version.collection
    authorize! version
    version.transaction do
      # delete the head version and revert to previous version
      revert_to_version = version.version - 1
      collection.update(head: collection.collection_versions.find_by(version: revert_to_version))
      version.destroy
    end

    redirect_to dashboard_path
  end

  def edit
    collection_version = CollectionVersion.find(params[:id])
    authorize! collection_version

    # if we end up on the edit page for a first draft (non-deposited collection), redirect to first draft edit page
    redirect_to edit_first_draft_collection_path(collection_version.collection) if collection_version.first_draft?

    @form = DraftCollectionVersionForm.new(collection_version)
    @form.prepopulate!
  end

  def update
    collection_version = CollectionVersion.find(params[:id])
    clean_params = collection_params
    if collection_version.deposited?
      NewCollectionVersionParameterFilter.call(clean_params, collection_version)
      collection_version = create_new_version(collection_version)
    end

    authorize! collection_version
    @form = collection_form(collection_version)

    if @form.validate(clean_params) && @form.save
      after_save(collection: collection_version.collection, collection_version: collection_version)
    else
      render :edit, status: :unprocessable_entity
    end
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

  def collection_params
    params.require(:collection_version).permit(:name, :description,
                                               related_links_attributes: %i[_destroy id link_title url],
                                               contact_emails_attributes: %i[_destroy id email])
  end

  def collection_form(collection_version)
    return CollectionVersionForm.new(collection_version) if deposit_button_pushed?

    DraftCollectionVersionForm.new(collection_version)
  end
end
