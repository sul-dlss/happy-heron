# frozen_string_literal: true

module Admin
  # Displays the admin page
  class LockedItemsController < ApplicationController
    before_action :authenticate_user!
    verify_authorized

    def index
      authorize! :locked_item
      @items = Work.locked
    end
  end
end
