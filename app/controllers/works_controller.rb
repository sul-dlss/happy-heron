# frozen_string_literal: true

# The endpoint for CRUD about a Work
# rubocop:disable Metrics/ClassLength
class WorksController < ObjectsController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable
  verify_authorized except: %i[delete_button edit_button]

  def index
    @collection = Collection.find(params[:collection_id])
    authorize! @collection, to: :show?

    @works = authorized_scope(@collection.works, as: :edits, with: WorkVersionPolicy)
  end

  def show
    @work = Work.find(params[:id])
    authorize! @work.head
  end

  def new
    validate_work_types!
    collection = Collection.find(params[:collection_id])
    work = Work.new(collection:, owner: current_user)
    work_version = WorkVersion.new(work_type: params[:work_type], subtype: params[:subtype], work:)
    authorize! work_version

    @form = WorkForm.new(work_version:, work:)
    @form.prepopulate!
  end

  # rubocop:disable Metrics/AbcSize
  def edit
    work = Work.find(params[:id])
    work_version = work.head
    authorize! work_version

    if invalid_version_for_edit?(work, work_version)
      WorksMailer.with(work:).version_mismatch_email.deliver_later
      flash.notice = I18n.t('work.flash.cannot_edit')
      return redirect_back(fallback_location: dashboard_path), status: :see_other
    end

    @form = WorkForm.new(work_version:, work: work_version.work)
    @form.prepopulate!
  end
  # rubocop:enable Metrics/AbcSize

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

  # rubocop:disable Metrics/AbcSize
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
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

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

  def files_list
    work = Work.find(params[:id])
    work_version = work.head
    root_directory = FileHierarchyService.to_hierarchy(work_version:)

    authorize! work_version, to: :show?

    render partial: 'works/files_list', locals: { work:, root_directory: }
  end

  # We render this button lazily because it requires doing a query to see if the user has access.
  # The access can vary depending on the user and the state of the work.
  def delete_button
    work = Work.find(params[:id])
    render partial: 'works/delete_button', locals: { work:, anchor: params[:tag] }
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

  def globus_user_valid?(user_id)
    return Settings.globus.test_user_valid if Settings.globus.test_mode && Rails.env.development?

    GlobusClient.user_valid?(user_id)
  end

  # Create the next WorkVersion for this work
  def create_new_version(previous_version)
    previous_version.dup.tap do |work_version|
      work_version.state = 'version_draft'
      work_version.version = previous_version.version + 1
      # reset globus endpoint
      work_version.globus_endpoint = nil
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

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def after_save(form:, event_context:)
    work_version = form.model[:work_version]
    work = form.model[:work]
    work.event_context = event_context
    work_version.update_metadata!

    # Instead of crazy conditional logic, constructing the event name and sending
    state_event = state_event_for(work_version)
    if state_event
      work_version.send(state_event)
      if state_event.starts_with?('fetch_globus')
        FetchGlobusJob.perform_later(work_version)
      elsif state_event.starts_with?('unzip')
        UnzipJob.perform_later(work_version)
      end
    end

    return redirect_to next_step_review_work_path(work) if deposit_button_pushed? && work.collection.review_enabled?
    return redirect_to next_step_work_path(work) if deposit_button_pushed?

    redirect_to work
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def state_event_for(work_version)
    event_parts = [file_event_part(work_version), workflow_event_part(work_version.work)].compact

    return if event_parts.empty?

    "#{event_parts.join('_and_')}!"
  end

  def file_event_part(work_version)
    if work_version.zipfile? && work_version.attached_files.any?
      'unzip'
    elsif fetch_globus_files?
      'fetch_globus'
    end
  end

  def workflow_event_part(work)
    if deposit_button_pushed? && work.collection.review_enabled?
      'submit_for_review'
    elsif deposit_button_pushed?
      'begin_deposit'
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

  def work_params
    params
      .require(:work)
      .permit(:title, :work_type,
              'published(1i)', 'published(2i)', 'published(3i)',
              :created_type,
              'created(1i)', 'created(2i)', 'created(3i)', 'created(approx0)',
              'created_range(1i)', 'created_range(2i)', 'created_range(3i)',
              'created_range(approx0)',
              'created_range(4i)', 'created_range(5i)', 'created_range(6i)',
              'created_range(approx3)',
              :abstract, :citation_auto, :citation, :default_citation,
              :access, :license, :custom_rights, :version_description,
              :release, 'embargo_date(1i)', 'embargo_date(2i)', 'embargo_date(3i)',
              :agree_to_terms, :assign_doi, :upload_type, :globus, :fetch_globus_files,
              :globus_origin, subtype: [], files: [],
                              attached_files_attributes: %i[_destroy id label hide file path],
                              authors_attributes: [:_destroy, :id, :full_name, :first_name, :last_name,
                                                   :contributor_type, :role, :weight, :orcid, :with_orcid,
                                                   { affiliations_attributes: affiliation_attributes }],
                              contributors_attributes: [:_destroy, :id, :full_name, :first_name, :last_name,
                                                        :contributor_type, :role, :weight, :orcid, :with_orcid,
                                                        { affiliations_attributes: affiliation_attributes }],
                              contact_emails_attributes: %i[_destroy id email],
                              keywords_attributes: %i[_destroy id label uri cocina_type],
                              related_works_attributes: %i[_destroy id citation],
                              related_links_attributes: %i[_destroy id link_title url])
  end

  def affiliation_attributes
    %i[_destroy id label department uri]
  end

  # rubocop:disable Metrics/AbcSize
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
  # rubocop:enable Metrics/AbcSize

  def fetch_globus_files?
    params[:work][:fetch_globus_files] == 'true'
  end

  def invalid_version_for_edit?(work, work_version)
    # Development does not have SDR API, so stubbing out the version check
    if Rails.env.development?
      # This allows for local testing by adding ?invalid_version=true
      return params[:invalid_version].present?
    end

    # If we are are about to create a new work_version (i.e. the current work_verion state is `deposited`)
    # than the work_version number will match the currently deposited version in SDR, and we should verify
    # that the next (about to be current) version number is valid.
    # If we have a work_version in a draft state, we have already created a new work_version with a version
    # number that is one larger than the current deposited version in SDR. Therefore, when we save a draft
    # of a work_version, we should expect that the current version number in H2 is already one ahead of SDR,
    # and we should verify that the current version number is valid.

    new_version_number = if work_version.deposited?
                           work_version.version + 1
                         else
                           work_version.version
                         end
    work.druid && !Repository.valid_version?(druid: work.druid, h2_version: new_version_number)
  end
end
# rubocop:enable Metrics/ClassLength
