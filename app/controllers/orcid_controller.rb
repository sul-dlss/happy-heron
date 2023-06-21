# typed: true
# frozen_string_literal: true

# Display the contributor with ORCID
class OrcidController < ApplicationController
  def search
    result = OrcidService.lookup(orcid: params[:id])

    if result.success?
      render json: {orcid: params[:id], first_name: result.value![0], last_name: result.value![1]}
    else
      head result.failure
    end
  end
end
