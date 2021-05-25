# typed: false
# frozen_string_literal: true

# Handles updates for first drafts of collections.
# When updating a first draft of a collection, you need to show a form that includes both
# the settings and the details all in one page.  For later versions, the form is split in two.
class FirstDraftCollectionsController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable

  def new
    collection = Collection.new(creator: current_user)
    authorize! collection

    collection_version = CollectionVersion.new(collection: collection)
    @form = CreateCollectionForm.new(collection_version: collection_version, collection: collection)
    @form.prepopulate!
  end

  # rubocop:disable Metrics/AbcSize
  def create
    collection = Collection.new(creator: current_user)
    authorize! collection

    collection_version = CollectionVersion.new(collection: collection)
    @form = collection_form(collection_version)
    if @form.validate(create_params) && @form.save
      collection_version.collection.event_context = { user: current_user }
      collection_version.update_metadata!
      collection_version.begin_deposit! if deposit_button_pushed?
      redirect_to collection_path(collection)
    else
      render :new, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def edit
    collection = Collection.find(params[:id])
    authorize! collection

    # if we end up on the edit page for a version draft (deposited collection), redirect to the regular edit page
    redirect_to edit_collection_path(collection) unless collection.head.first_draft?

    collection_version = collection.collection_versions.first # this is a first draft and should only have one version
    @form = CreateCollectionForm.new(collection_version: collection_version, collection: collection)
    # @form = CollectionSettingsForm.new(collection)
    @form.prepopulate!
  end

  # rubocop:disable Metrics/AbcSize
  def update
    collection = Collection.find(params[:id])
    authorize! collection

    collection_version = collection.head
    @form = collection_form(collection_version)
    if @form.validate(create_params) && @form.save
      collection_version.update_metadata!
      if deposit_button_pushed?
        collection_version.begin_deposit!
        redirect_to dashboard_path
      else
        redirect_to collection_path(collection)
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def collection_form(collection_version)
    if deposit_button_pushed?
      return CreateCollectionForm.new(collection_version: collection_version,
                                      collection: collection_version.collection)
    end

    DraftCollectionForm.new(collection_version: collection_version, collection: collection_version.collection)
  end

  def create_params
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
