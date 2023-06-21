# frozen_string_literal: true

# A class for the user model presentation
class UserPresenter
  def initialize(user:)
    @model = user
  end

  attr_reader :model

  def name
    model.name || "New SDR User" # return either the name in the database or a default if none exists (i.e. new users)
  end

  def first_name
    model.first_name || "New SDR User" # return either the first_name in the database or a default if none exists
  end

  delegate :email, to: :model
end
