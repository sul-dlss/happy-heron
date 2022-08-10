# frozen_string_literal: true

# The endpoint for CRUD about a Reserved PURL
class ReservationsController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable
  verify_authorized except: %i[delete_button edit_button]

  def create
    work = Work.new(collection_id: params[:collection_id], depositor: current_user, owner: current_user)
    work_version = WorkVersion.new(work: work)

    authorize! work_version

    @form = ReservationForm.new(work_version: work_version, work: work)
    if @form.validate(work_params) && @form.save
      work_version.reserve_purl!
      redirect_to dashboard_path
    else
      head :bad_request
    end
  end

  def update # rubocop:disable Metrics/AbcSize
    work = Work.find(params[:id])
    work_version = work.head
    authorize! work_version, to: :update_type?

    work_version.work_type = params[:work_type]
    work_version.subtype = params[:subtype]

    unless work_version.valid?
      return redirect_to dashboard_path, status: :see_other,
                                         flash: { error: 'Invalid subtype value' }
    end

    work_version.transaction do
      work.events.create(user: current_user, event_type: 'type_selected')
      work_version.update_metadata! # This causes a save
    end

    # from https://apidock.com/rails/ActionController/Redirecting/redirect_to
    # "If you are using XHR requests other than GET or POST and redirecting after the request then some
    # browsers will follow the redirect using the original request method... To work around this... return
    # a 303 See Other status code which will be followed using a GET request."
    redirect_to edit_work_path(work), status: :see_other
  end

  private

  def work_params
    params.require(:work).permit(:title, :work_type, :assign_doi, subtype: [])
  end
end
