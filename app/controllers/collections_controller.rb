# typed: false
# frozen_string_literal: true

# Handles CRUD for Collections
class CollectionsController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def new
    @collection = Collection.new(managers: current_user.email,
                                 visibility: 'world')
    authorize! @collection
  end

  def create
    @collection = Collection.new(collection_params.merge(creator: current_user))
    authorize! @collection

    if @collection.save
      # TODO: https://github.com/sul-dlss/happy-heron/issues/92
      # DepositCollectionJob.perform_later(@collection) if params[:commit] == 'Deposit'
      redirect_to dashboard_path
    else
      render :new
    end
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :description, :contact_email,
                                       :visibility, :managers)
  end
end
