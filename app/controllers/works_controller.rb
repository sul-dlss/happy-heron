# typed: false
# frozen_string_literal: true

# The endpoint for CRUD about a Work
# rubocop:disable Metrics/ClassLength
class WorksController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable
  verify_authorized except: %i[delete_button edit_button]

  def new
    validate_work_types!
    collection = Collection.find(params[:collection_id])
    work = Work.new(collection: collection)
    work_version = WorkVersion.new(work_type: params[:work_type], subtype: params[:subtype], work: work)
    authorize! work_version

    @form = WorkForm.new(work_version: work_version, work: work)
    @form.prepopulate!
  end

  def create
    work = Work.new(collection_id: params[:collection_id], depositor: current_user)
    work_version = WorkVersion.new(work: work)

    authorize! work_version

    @form = work_form(work_version)
    if @form.validate(work_params) && @form.save
      after_save(form: @form)
    else
      @form.prepopulate!
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    work = Work.find(params[:id])
    work_version = work.head
    authorize! work_version

    @form = WorkForm.new(work_version: work_version, work: work_version.work)
    @form.prepopulate!
  end

  def update_type
    work = Work.find(params[:id])
    work_version = work.head
    authorize! work_version

    begin
      work_version.choose_type_for_purl_reservation(params[:work_type], params[:subtype], current_user)

      # from https://apidock.com/rails/ActionController/Redirecting/redirect_to
      # "If you are using XHR requests other than GET or POST and redirecting after the request then some
      # browsers will follow the redirect using the original request method... To work around this... return
      # a 303 See Other status code which will be followed using a GET request."
      redirect_to action: 'edit', status: :see_other
    rescue ActiveRecord::RecordInvalid => e
      validate_work_types! if /Validation failed/i.match?(e.message)
    rescue WorkVersion::WorkTypeUpdateError
      flash[:error] = 'Unexpected error attempting to edit PURL reservation'
      redirect_to dashboard_path, status: :see_other
    end
  end

  def update
    work = Work.find(params[:id])
    work_version = work.head
    clean_params = work_params

    if work_version.deposited?
      work_version = create_new_version(work_version)
      NewVersionParameterFilter.call(clean_params, work.head)
    end

    authorize! work_version

    @form = work_form(work_version)
    if @form.validate(clean_params) && @form.save
      after_save(form: @form)
    else
      @form.prepopulate!
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @collection = Collection.find(params[:collection_id])
    authorize! @collection, to: :show?

    @works = authorized_scope(@collection.works, as: :edits, with: WorkVersionPolicy)
  end

  def show
    @work = Work.find(params[:id])
    authorize! @work.head
  end

  def destroy
    work = Work.find(params[:id])
    collection = work.collection
    authorize! work
    work.transaction do
      work.update(head: nil)
      work.destroy
    end

    redirect_to collection_works_path(collection)
  end

  def next_step
    @work = Work.find(params[:id])

    authorize! @work.head, to: :show?
  end

  def next_step_review
    @work = Work.find(params[:id])

    authorize! @work.head, to: :show?
  end

  # We render this button lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the work.
  def delete_button
    work = Work.find(params[:id])
    render partial: 'works/delete_button', locals: { work: work }
  end

  # We render this button lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the work.
  def edit_button
    work = Work.find(params[:id])
    render partial: 'works/edit_button', locals: { work: work }
  end

  def normalize_key(key)
    keys = { attached_files: 'file', embargo_date: 'embargo-date' }
    return key unless keys.key? key

    keys[key]
  end
  helper_method :normalize_key

  private

  # Create the next WorkVersion for this work
  def create_new_version(previous_version)
    previous_version.dup.tap do |work_version|
      work_version.state = 'version_draft'
      work_version.version = previous_version.version + 1
      CollectionObserver.version_draft_created(work_version, nil)
    end
  end

  sig { params(work_version: WorkVersion).returns(Reform::Form) }
  def work_form(work_version)
    if purl_reservation?
      ReservationForm.new(work_version: work_version, work: work_version.work)
    elsif deposit_button_pushed?
      WorkForm.new(work_version: work_version, work: work_version.work)
    else
      DraftWorkForm.new(work_version: work_version, work: work_version.work)
    end
  end

  sig { params(form: T.any(ReservationForm, WorkForm, DraftWorkForm)).void }
  def after_save(form:) # rubocop:disable Metrics/MethodLength
    work_version = form.model[:work_version]

    if purl_reservation?
      work_version.reserve_purl!
      return redirect_to dashboard_path
    end

    work = form.model[:work]
    work.event_context = event_context(form)
    work_version.update_metadata!

    return redirect_to work unless deposit_button_pushed?

    if work.collection.review_enabled?
      work_version.submit_for_review!
      redirect_to next_step_review_work_path(work)
    else
      work_version.begin_deposit!
      redirect_to next_step_work_path(work)
    end
  end

  def event_context(form)
    {
      user: current_user,
      description: WorkVersionEventDescriptionBuilder.build(form)
    }
  end

  # rubocop:disable Metrics/MethodLength
  def work_params
    top_level = T.cast(params.require(:work), ActionController::Parameters)
    top_level.permit(:title, :work_type,
                     'published(1i)', 'published(2i)', 'published(3i)',
                     :created_type,
                     'created(1i)', 'created(2i)', 'created(3i)', 'created(approx0)',
                     'created_range(1i)', 'created_range(2i)', 'created_range(3i)',
                     'created_range(approx0)',
                     'created_range(4i)', 'created_range(5i)', 'created_range(6i)',
                     'created_range(approx3)',
                     :abstract, :citation_auto, :citation, :default_citation,
                     :access, :license, :description,
                     :release, 'embargo_date(1i)', 'embargo_date(2i)', 'embargo_date(3i)',
                     :agree_to_terms,
                     subtype: [],
                     attached_files_attributes: %i[_destroy id label hide file],
                     authors_attributes: %i[_destroy id full_name first_name last_name role_term weight],
                     contributors_attributes: %i[_destroy id full_name first_name last_name role_term],
                     contact_emails_attributes: %i[_destroy id email],
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
      errors << "Invalid subtype value for work of type '#{params[:work_type]}': " +
                (Array(params[:subtype]).join.presence || 'missing')
    end

    return if errors.empty?

    flash[:error] = errors.join("\n")
    redirect_to dashboard_path, status: :see_other
  end

  def purl_reservation?
    params[:purl_reservation] == 'true'
  end
end
# rubocop:enable Metrics/ClassLength
