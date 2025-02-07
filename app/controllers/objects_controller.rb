# frozen_string_literal: true

# a contoller that has methods useful to works and collections controllers
class ObjectsController < ApplicationController
  private

  def deposit_button_pushed?
    ['Deposit', 'Submit for approval'].include?(params[:commit])
  end
end
