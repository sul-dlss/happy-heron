# frozen_string_literal: true

# a controller for changing the collection of work.
class WorkMoveController < ApplicationController
  before_action :authenticate_user!
  verify_authorized

  def search
    authorize! :work_move

    work = Work.find(params[:id])
    collections = Collection.where(druid: "druid:#{params[:druid]}")

    render json: collections.map { |collection| collection_json(collection, work) }
  end

  def edit
    work = Work.find(params[:id])
    authorize! work, to: :move_collection?
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def update
    work = Work.find(params[:id])
    authorize! work, to: :move_collection?

    collection = Collection.find(params[:collection])

    if CheckMoveWorkService.check(work:, collection:).any?
      flash[:error] = I18n.t('work.flash.work_not_moved')
    else
      Work.transaction do
        current_collection = work.collection
        collection.depositors << work.owner unless collection.depositors.include?(work.owner)
        collection.save!
        work.update!(collection:)
        description = "Moved from \"#{current_collection.head.name}\" to \"#{collection.head.name}\" collection"
        work.events.create(user: current_user, event_type: 'collection_moved', description:)
      end
      flash[:success] = "Moved #{work.head.title} to #{collection.head.name}"
    end

    redirect_to work_path(work), status: :see_other
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  def collection_json(collection, work)
    {
      id: collection.id,
      name: collection.head.name,
      druid: collection.druid,
      errors: CheckMoveWorkService.check(work:, collection:)
    }
  end
end
