# frozen_string_literal: true

# a controller for changing work types and subtypes.
class WorkTypesController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def edit
    authorize! :work_owner

    @work = Work.find(params[:id])
    @form_authenticity_token = form_authenticity_token
  end

  def update
    authorize! :work_owner

    work = Work.find(params[:id])
    update_work_type(work, params[:work_type], params[:subtype])
    flash[:success] = "New draft created with changed work type / subtypes."
    redirect_to edit_work_path(work)
  end

  private

  def update_work_type(work, work_type, subtypes)
    original_version = work.head
    new_version = NewVersionService.dup(work.head, increment_version: true, save: true, version_description: "work type changed", state: :version_draft) do |work_version|
      work_version.work_type = work_type
      work_version.subtype = subtypes || []
    end
    new_version.work.event_context = {user: current_user, description: description_for(original_version, new_version)}
    new_version.update_metadata!
  end

  def description_for(original_version, new_version)
    return "work type modified, subtypes modified" if original_version.work_type != new_version.work_type && original_version.subtype != new_version.subtype
    return "work type modified" if original_version.work_type != new_version.work_type
    "subtypes modified" if original_version.subtype != new_version.subtype
  end
end
