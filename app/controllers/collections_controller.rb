# typed: false
# frozen_string_literal: true

# Handles CRUD for Collections
class CollectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_sdr_updatable
  verify_authorized

  def new
    collection = Collection.new(creator: current_user)
    authorize! collection

    @form = CollectionForm.new(collection)
    @form.prepopulate!
  end

  def edit
    collection = Collection.find(params[:id])
    authorize! collection

    @form = CollectionForm.new(collection)
    @form.prepopulate!
  end

  def create
    collection = Collection.new(creator: current_user)
    authorize! collection

    @form = collection_form(collection)
    if @form.validate(collection_params) && @form.save
      # TODO: https://github.com/sul-dlss/happy-heron/issues/92
      # DepositCollectionJob.perform_later(@collection) if deposit?
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def update
    collection = Collection.find(params[:id])
    authorize! collection

    @form = collection_form(collection)
    if @form.validate(collection_params) && @form.save
      # TODO: https://github.com/sul-dlss/happy-heron/issues/92
      # DepositCollectionJob.perform_later(@collection) if deposit?
      redirect_to dashboard_path
    else
      render :edit
    end
  end

  private

  def collection_form(collection)
    return CollectionForm.new(collection) if deposit?

    DraftCollectionForm.new(collection)
  end

  def collection_params
    params.require(:collection).permit(:name, :description, :contact_email,
                                       :access, :managers, :depositor_sunets,
                                       :review_enabled, :reviewer_sunets)
  end
end
