# typed: false
# frozen_string_literal: true

# Renders the progress component given the form values
class ValidatesController < ApplicationController
  # rubocop:disable Metrics/AbcSize
  def show
    if params[:work_id]
      work = Work.find(params[:work_id])
      work_version = work.head
    else
      work = Work.new(collection_id: params[:collection_id])
      work_version = WorkVersion.new(work: work)
    end
    form = WorkForm.new(work: work, work_version: work_version)
    form.validate(params[:work])
    # If you call sync on a persisted model, ActiveRecord will overwrite has_many assocations.
    # If you don't call sync on a new record, it won't show any of the validations.
    form.sync unless work.persisted?
    render partial: 'validate', locals: { work_version: work_version }
  end
  # rubocop:enable Metrics/AbcSize

  # Prevent long URLs (in the ValidatesController) from getting serialized into
  # the cookie causing a CookieOverflow
  # See https://github.com/heartcombo/devise/pull/3347
  # overrides Devise::Controllers::StoreLocation
  def store_location_for(resource_or_scope, location)
    # NOP
  end
end
