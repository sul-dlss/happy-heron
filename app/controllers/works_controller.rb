# typed: false
# frozen_string_literal: true

class WorksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :ensure_sdr_updatable

  def new
    @collection = Collection.find(params[:collection_id])
    @work = Work.new(work_type: 'text',
                     subtype: 'manuscript',
                     collection: @collection,
                     contributors: [Contributor.new])
  end

  def create
    @collection = Collection.find(params[:collection_id])
    @work = Work.new(work_params.merge(collection: @collection))
    if @work.save
      DepositJob.perform_later(@work) if params[:commit] == 'Deposit'
      redirect_to @work
    else
      render :new
    end
  end

  def show
    @work = Work.find(params[:id])
  end

  private

  def work_params
    params.require(:work).permit(:title, :work_type, :subtype, :contact_email,
                                 :created_edtf, :abstract, :citation, :access, :license, :agree_to_terms,
                                 files: [],
                                 contributors_attributes: %i[_destroy id first_name last_name role_term_id])
  end
end
