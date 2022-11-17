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
    work = Work.new(collection:, owner: current_user)
    work_version = WorkVersion.new(work_type: params[:work_type], subtype: params[:subtype], work:)
    authorize! work_version

    @form = WorkForm.new(work_version:, work:)
    @form.prepopulate!
  end

  def create
    work = Work.new(collection_id: params[:collection_id], depositor: current_user, owner: current_user)
    work_version = WorkVersion.new(work:)

    authorize! work_version

    @form = work_form(work_version)
    if @form.validate(work_params) && @form.save
      after_save(form: @form, event_context: build_event_context(@form))
    else
      @form.prepopulate!
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    work = Work.find(params[:id])
    work_version = work.head
    authorize! work_version

    @form = WorkForm.new(work_version:, work: work_version.work)
    @form.prepopulate!
  end

  # rubocop:disable Metrics/MethodLength
  def update
    work = Work.find(params[:id])
    work_version = work.head
    orig_work_version = work.head
    orig_clean_params = work_params
    clean_params = orig_clean_params.deep_dup

    if work_version.deposited?
      work_version = create_new_version(work_version)
      NewVersionParameterFilter.call(clean_params, work.head)
    end

    authorize! work_version

    @form = work_form(work_version)
    # `changed?(field)` on a reform form object needs to be asked before persistence on existing records
    event_context = build_event_context(context_form(orig_work_version, orig_clean_params))
    if @form.validate(clean_params) && @form.save
      after_save(form: @form, event_context:)
    else
      @form.prepopulate!
      render :edit, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/MethodLength

  def index
    @collection = Collection.find(params[:collection_id])
    authorize! @collection, to: :show?

    @works = authorized_scope(@collection.works, as: :edits, with: WorkVersionPolicy)
  end

  def show
    @work = Work.find(params[:id])
    authorize! @work.head
  end

  def details
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

    redirect_path = request.referer.include?('dashboard') ? dashboard_path : collection_works_path(collection)
    redirect_to redirect_path, status: :see_other
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
    render partial: 'works/delete_button', locals: { work: }
  end

  # We render this button lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the work.
  # (e.g. a depositor can not edit a work they have submitted for review)
  def edit_button
    work = Work.find(params[:id])

    default_label = if work.purl_reservation?
                      "Choose Type and Edit #{WorkTitlePresenter.show(work.head)}"
                    else
                      "Edit #{WorkTitlePresenter.show(work.head)}"
                    end
    edit_label = I18n.t params[:tag], scope: %i[work edit_links], default: default_label

    render partial: 'works/edit_button', locals: { work:, anchor: params[:tag], edit_label: }
  end

  private

  # Create the next WorkVersion for this work
  def create_new_version(previous_version)
    previous_version.dup.tap do |work_version|
      work_version.state = 'version_draft'
      work_version.version = previous_version.version + 1
      CollectionObserver.version_draft_created(work_version, nil)
    end
  end

  def work_form(work_version)
    if deposit_button_pushed?
      WorkForm.new(work_version:, work: work_version.work)
    else
      DraftWorkForm.new(work_version:, work: work_version.work)
    end
  end

  def after_save(form:, event_context:)
    work_version = form.model[:work_version]
    work = form.model[:work]
    work.event_context = event_context
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

  # used to build event context from creating or updating an existing work
  def build_event_context(form)
    {
      user: current_user,
      description: WorkVersionEventDescriptionBuilder.build(form)
    }
  end

  def context_form(work_version, params)
    # NewVersionParameterFilter removes collection parameters, which makes it seem like they have changed.
    # This form has the unfiltered parameters, which is used to determine what has changed.
    context_form = work_form(work_version)
    context_form.validate(params)
    context_form
  end

  # rubocop:disable Metrics/MethodLength
  def work_params
    top_level = params.require(:work)
    top_level.permit(:title, :work_type,
                     'published(1i)', 'published(2i)', 'published(3i)',
                     :created_type,
                     'created(1i)', 'created(2i)', 'created(3i)', 'created(approx0)',
                     'created_range(1i)', 'created_range(2i)', 'created_range(3i)',
                     'created_range(approx0)',
                     'created_range(4i)', 'created_range(5i)', 'created_range(6i)',
                     'created_range(approx3)',
                     :abstract, :citation_auto, :citation, :default_citation,
                     :access, :license, :version_description,
                     :release, 'embargo_date(1i)', 'embargo_date(2i)', 'embargo_date(3i)',
                     :agree_to_terms, :assign_doi, :upload_type,
                     subtype: [],
                     attached_files_attributes: %i[_destroy id label hide file],
                     authors_attributes: %i[_destroy id full_name first_name last_name role_term weight orcid],
                     contributors_attributes: %i[_destroy id full_name first_name last_name role_term weight orcid],
                     contact_emails_attributes: %i[_destroy id email],
                     keywords_attributes: %i[_destroy id label uri cocina_type],
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
      errors << ("Invalid subtype value for work of type '#{params[:work_type]}': " +
                (Array(params[:subtype]).join.presence || 'missing'))
    end

    return if errors.empty?

    flash[:error] = errors.join("\n")
    redirect_to dashboard_path, status: :see_other
  end
end
# rubocop:enable Metrics/ClassLength
