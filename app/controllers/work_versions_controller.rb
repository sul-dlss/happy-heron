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

    if version.version == 1
      destroy_work(work)
    else
      revert_head_version(version)
    end

    redirect_to collection_works_path(collection)
  end

  private

  def destroy_work(work)
    work.transaction do
      work.update!(head: nil)
      work.destroy!
    end
  end

  def revert_head_version(version)
    work = version.work
    version.transaction do
      # delete the head version and revert to previous version
      work.update!(head: work.work_versions.find_by(version: version.version - 1))
      version.destroy!
    end
  end
end
