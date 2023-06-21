# frozen_string_literal: true

module Admin
  # Search by druid and view a collection or work
  class DruidSearchesController < ApplicationController
    include Dry::Monads[:result]

    before_action :authenticate_user!
    verify_authorized

    def index
      authorize! :druid_search
      return unless params[:query]

      result = lookup_druid(params[:query])
      return @failure = true if result.failure?

      item = result.value!
      redirect_to item.is_a?(Collection) ? item.head : item
    end

    private

    def lookup_druid(druid)
      druid = "druid:#{druid}" unless druid.start_with?("druid:")
      item = Collection.find_by(druid:) || Work.find_by(druid:)
      return Failure(:not_found) unless item

      Success(item)
    end
  end
end
