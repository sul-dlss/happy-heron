# frozen_string_literal: true

# Provides an endpoint to download a zip file of all attached files
class ZipsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized except: %i[delete_button edit_button]
  include Zipline

  def show
    work = Work.find(params[:work_id])
    work_version = work.head
    authorize! work_version
    files = collect_files(work_version)

    raise ActionController::RoutingError, 'No downloadable files' if files.none?

    zipline(files, "#{work.druid.presence || work.id}.zip")
  end

  private

  def collect_files(work_version)
    work_version.attached_files.map do |af|
      af.transform_blob_to_preservation if af.in_preservation?
      [
        af.file,
        af.file.filename
      ]
    end
  end
end
