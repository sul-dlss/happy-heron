# typed: false
# frozen_string_literal: true

class WorksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :ensure_sdr_updatable

  def new
    collection = Collection.find(params[:collection_id])
    raise 'Missing required parameter work_type' unless params[:work_type]

    work = Work.new(work_type: params[:work_type],
                    collection: collection,
                    contributors: [Contributor.new])
    @form = WorkForm.new(work)
  end

  def create
    work = Work.new
    @form = WorkForm.new(work)

    stuff = work_params.merge(collection_id: params[:collection_id])
    if @form.validate(stuff) && @form.save
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
                                 :created_edtf, :abstract, :citation, :access, :license, :agree_to_terms,
                                 subtype: [],
                                 attached_files_attributes: %i[_destroy id label hide file],
                                 contributors_attributes: %i[_destroy id first_name last_name role_term])
  end
end
