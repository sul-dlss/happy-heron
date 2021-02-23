# typed: false
# frozen_string_literal: true

# The endpoint for CRUD about a CollectionVersions
class CollectionVersionsController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable, except: [:destroy]
  verify_authorized

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
end
