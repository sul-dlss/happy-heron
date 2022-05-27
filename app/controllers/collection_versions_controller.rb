# frozen_string_literal: true

# The endpoint for CRUD about a CollectionVersions
class CollectionVersionsController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable, except: [:destroy]
  verify_authorized except: %i[edit_link]

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
      after_save(form: @form)
    else
      @form.prepopulate!
      render :edit, status: :unprocessable_entity
    end
  end

  # We render this link lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the collection.
  def edit_link
    collection_version = CollectionVersion.find(params[:id])
    render partial: 'edit_link', locals: {
      collection_version: collection_version,
      name: collection_version.name
    }
  end

  private

  # Create the next CollectionVersion for this Collection
  def create_new_version(previous_version)
    previous_version.dup.tap do |collection_version|
      collection_version.state = 'version_draft'
      collection_version.version = previous_version.version + 1
    end
  end

  def after_save(form:)
    collection_version = form.model
    collection_version.collection.event_context = event_context(form)
    collection_version.update_metadata!
    if deposit_button_pushed?
      collection_version.begin_deposit!
      redirect_to dashboard_path
    else
      redirect_to collection_version_path(collection_version)
    end
  end

  def event_context(form)
    {
      user: current_user,
      description: CollectionVersionEventDescriptionBuilder.build(form)
    }
  end

  def collection_params
    params.require(:collection_version).permit(:name, :description, :version_description,
                                               related_links_attributes: %i[_destroy id link_title url],
                                               contact_emails_attributes: %i[_destroy id email])
  end

  def collection_form(collection_version)
    return CollectionVersionForm.new(collection_version) if deposit_button_pushed?

    DraftCollectionVersionForm.new(collection_version)
  end
end
