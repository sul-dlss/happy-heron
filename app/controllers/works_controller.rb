# frozen_string_literal: true

class WorksController < ApplicationController
  layout 'editor'

  def new
    @work = Work.new(work_type: 'text')
  end

  def create
    @work = Work.new(work_params)
    if @work.save
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
        :created_etdf, :abstract, :citation, :access, :license, :agree_to_terms,
        files: [])
    end
end
