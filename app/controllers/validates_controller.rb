# typed: false
# frozen_string_literal: true

# Renders the progress component given the form values
class ValidatesController < ApplicationController
  def show
    work = if params[:work_id]
             Work.find(params[:work_id])
           else
             Work.new(collection_id: params[:collection_id])
           end

    form = WorkForm.new(work)
    form.validate(params[:work])
    form.sync
    render partial: 'validate', locals: { work: work }
  end

  # Prevent long URLs (in the ValidatesController) from getting serialized into
  # the cookie causing a CookieOverflow
  # See https://github.com/heartcombo/devise/pull/3347
  # overrides Devise::Controllers::StoreLocation
  def store_location_for(resource_or_scope, location)
    # NOP
  end
end
