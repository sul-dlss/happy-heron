# frozen_string_literal: true

# a contoller that has methods useful to works and collections controllers
class ObjectsController < ApplicationController
  protected

  def deposit_button_pushed?
    params[:commit] == 'Deposit' || params[:commit] == 'Submit for approval'
  end
end
