# frozen_string_literal: true

# a controller for decommissioning a collection.
class CollectionDecommissionController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def edit
    authorize! :collection_decommission
  end

  def update
    authorize! :collection_decommission

    collection = Collection.find(params[:id])
    # Check that collection contains only NO items or ONLY DECOMMISSIONED items
    if collection.works_without_decommissioned.any?
      flash[:error] = I18n.t('collection.flash.decommission_failed')
    else
      decommission!(collection)
      flash[:success] = I18n.t('collection.flash.decommissioned')
    end
    redirect_to collection_path(collection)
  end

  private

  def decommission!(collection)
    Collection.transaction do
      # NOTE: You might think the `head.collection` bit here is not needed...
      #       but it is. Why? Because when the event is created in the
      #       CollectionVersion class, we access the collection **via** the
      #       collection version. And that in-memory collection instance is a
      #       different in-memory collection instance than the collection here.
      collection.head.collection.event_context = {
        user: current_user,
        description: I18n.t('collection.flash.decommissioned')
      }
      collection.head.decommission!
      collection.update!(
        managed_by: [],
        depositors: [],
        reviewed_by: []
      )
    end
  end
end
