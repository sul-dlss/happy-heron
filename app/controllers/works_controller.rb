# typed: false
# frozen_string_literal: true

# The endpoint for CRUD about a Work
class WorksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
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
    work = Work.new(collection_id: params[:collection_id])
    authorize! work

    @form = WorkForm.new(work)
    if @form.validate(work_params) && @form.save
      DepositJob.perform_later(work) if params[:commit] == 'Deposit'
      redirect_to work
    else
      render :new
    end
  end

  def show
    @work = Work.find(params[:id])
  end

  private

  def work_params
    params.require(:work).permit(:title, :work_type, :contact_email,
                                 'published(1i)', 'published(2i)', 'published(3i)',
                                 :creation_type,
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

  def validate_work_types!
    errors = []

    unless WorkTypeValidator.valid?(params[:work_type])
      errors << "Invalid value of required parameter work_type: #{params[:work_type].presence || 'nil'}"
    end

    unless WorkSubtypeValidator.valid?(params[:work_type], params[:subtype])
      errors << "Invalid subtype value for work_type '#{params[:work_type]}': #{params[:subtype].join}"
    end

    return if errors.empty?

    flash[:error] = errors.join("\n")
    redirect_to dashboard_path
  end
end
