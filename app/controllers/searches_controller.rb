# typed: false
# frozen_string_literal: true

# When a user searches for a druid, direct them to the correct path.
class SearchesController < ApplicationController
  def show
    druid = params[:q]
    druid = "druid:#{druid}" unless druid.start_with?('druid:')
    result = Work.find_by(druid: druid) || Collection.find_by(druid: druid)
    return render js: "window.location='#{polymorphic_path(result)}'" if result

    render json: { message: 'not found' }, status: :not_found
  end
end
