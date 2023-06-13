# frozen_string_literal: true

module Admin
  # Search by work_version and view a work
  class WorkVersionSearchesController < ApplicationController
    include Dry::Monads[:result]

    before_action :authenticate_user!
    verify_authorized

    def index
      authorize! :work_version_search
      return unless params[:query]

      result = lookup_work_version(params[:query])
      return @failure = true if result.failure?

      item = result.value!
      redirect_to item
    end

    private

    def lookup_work_version(work_version_id)
      item = WorkVersion.find_by(id: work_version_id)
      return Failure(:not_found) unless item

      Success(item.work)
    end
  end
end
