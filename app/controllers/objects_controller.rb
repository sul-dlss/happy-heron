# typed: false
# frozen_string_literal: true

# a contoller that has methods useful to works and collections controllers
class ObjectsController < ApplicationController
  protected

  def deposit?
    params[:commit] == 'Deposit'
  end
end
