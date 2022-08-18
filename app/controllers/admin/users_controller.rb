# frozen_string_literal: true

module Admin
  # Search and display a user
  class UsersController < ApplicationController
    include Dry::Monads[:result]

    before_action :authenticate_user!
    verify_authorized

    def index
      authorize!
      @result = build_presenter(User.find_by(email: params[:query] + User::EMAIL_SUFFIX)) if params[:query]
    end

    private

    def build_presenter(user)
      return Failure(:not_found) unless user

      presenter = Admin::UserPresenter.new(user: user,
                                           collections_created_by_user: user.created_collections,
                                           collections: user.collections_with_access,
                                           works: user.works_created_or_owned)
      Success(presenter)
    end
  end
end
