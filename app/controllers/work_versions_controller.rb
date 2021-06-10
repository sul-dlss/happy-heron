# typed: false
# frozen_string_literal: true

# The endpoint for CRUD about a WorkVersions
class WorkVersionsController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable, except: [:destroy]
  verify_authorized

  # Revert the work to the previously deposited version.
  def destroy
    version = WorkVersion.find(params[:id])
    work = version.work
    collection = work.collection
    authorize! version
    version.transaction do
      # delete the head version and revert to previous version
      revert_to_version = version.version - 1
      work.update(head: work.work_versions.find_by(version: revert_to_version))
      version.destroy
    end

    redirect_to collection_works_path(collection)
  end
end
