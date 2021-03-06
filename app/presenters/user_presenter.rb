# typed: true
# frozen_string_literal: true

# A class for the user model presentation
class UserPresenter
  extend T::Sig

  def initialize(user:)
    @model = user
  end

  attr_reader :model

  sig { returns(String) }
  def name
    model.name || 'New SDR User' # return either the name in the database or a default if none exists (i.e. new users)
  end

  delegate :email, to: :model
end
