# frozen_string_literal: true

# a controller for decommissioning a work.
class WorkDecommissionController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def edit
    authorize! :work_owner
  end

  def update
    authorize! :work_owner

    work = Work.find(params[:id])
    decommission(work)

    flash[:success] = I18n.t('work.flash.decommissioned')
    redirect_to work_path(work)
  end

  private

  def decommission(work)
    Work.transaction do
      work.update!(owner: current_user)
      delete_files(work)
      work.head.decommission!
    end
  end

  def delete_files(work)
    work.work_versions.each do |work_version|
      work_version.attached_files.each do |attached_file|
        attached_file.file.purge
        attached_file.destroy!
      end
    end
  end
end
