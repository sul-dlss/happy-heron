# frozen_string_literal: true

module Admin
  # This holds the data to be displayed when searching for a user
  class UserPresenter
    def initialize(user:, collections_created_by_user:, collections:, works:)
      @user = user
      @collections_created_by_user = collections_created_by_user
      @collections = collections
      @works = works
    end

    attr_reader :user, :works, :collections, :collections_created_by_user

    delegate :sunetid, :name, to: :user
  end
end
