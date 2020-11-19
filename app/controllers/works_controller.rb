# typed: true
# frozen_string_literal: true

# The endpoint for CRUD about a Work
class WorksController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable
  verify_authorized except: [:show]

  def new
    validate_work_types!
    collection = Collection.find(params[:collection_id])
    work = Work.new(work_type: params[:work_type],
                    subtype: params[:subtype],
                    collection: collection)
    authorize! work

    @form = WorkForm.new(work)
    @form.prepopulate!
  end

  def create
    work = Work.new(collection_id: params[:collection_id], depositor: current_user)
    authorize! work

    @form = work_form(work)
    if @form.validate(work_params) && @form.save
      after_save(work)
    else
      # Send form errors to client in JSON format to be parsed and rendered there
      render 'errors', status: :bad_request
    end
  end

  def edit
    work = Work.find(params[:id])
    authorize! work

    @form = WorkForm.new(work)
    @form.prepopulate!
  end

  def update
    work = Work.find(params[:id])
    authorize! work

    @form = work_form(work)
    if @form.validate(work_params) && @form.save
      EventService.new_version(work: work, user: current_user) if work.deposited?
      after_save(work)
    else
      # Send form errors to client in JSON format to be parsed and rendered there
      render 'errors', status: :bad_request
    end
  end

  def show
    @work = Work.find(params[:id])
  end

  private

  sig { params(work: Work).returns(Reform::Form) }
  def work_form(work)
    return WorkForm.new(work) if deposit_button_pushed?

    DraftWorkForm.new(work)
  end

  sig { params(work: Work).void }
  def after_save(work)
    if deposit_button_pushed?
      if work.collection.review_enabled?
        EventService.submit_for_review(work: work, user: current_user)
      else
        EventService.begin_deposit(work: work, user: current_user)
        DepositJob.perform_later(work)
      end
    end
    redirect_to work
  end

  # rubocop:disable Metrics/MethodLength
  def work_params
    top_level = T.cast(params.require(:work), ActionController::Parameters)
    top_level.permit(:title, :work_type, :contact_email,
                     'published(1i)', 'published(2i)', 'published(3i)',
                     :created_type,
                     'created(1i)', 'created(2i)', 'created(3i)',
                     'created_range(1i)', 'created_range(2i)', 'created_range(3i)',
                     'created_range(4i)', 'created_range(5i)', 'created_range(6i)',
                     :created_edtf, :abstract, :citation, :access, :license,
                     :release, 'embargo_date(1i)', 'embargo_date(2i)', 'embargo_date(3i)',
                     :agree_to_terms,
                     subtype: [],
                     attached_files_attributes: %i[_destroy id label hide file],
                     contributors_attributes: %i[_destroy id full_name first_name last_name role_term],
                     keywords_attributes: %i[_destroy id label uri],
                     related_works_attributes: %i[_destroy id citation],
                     related_links_attributes: %i[_destroy id link_title url])
  end
  # rubocop:enable Metrics/MethodLength

  def validate_work_types!
    errors = []

    unless WorkTypeValidator.valid?(params[:work_type])
      errors << "Invalid value of required parameter work_type: #{params[:work_type].presence || 'missing'}"
    end

    unless WorkSubtypeValidator.valid?(params[:work_type], params[:subtype])
      errors << "Invalid subtype value for work_type '#{params[:work_type]}': " +
                (Array(params[:subtype]).join.presence || 'missing')
    end

    return if errors.empty?

    flash[:error] = errors.join("\n")
    redirect_to dashboard_path
  end
end
