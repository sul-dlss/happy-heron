# typed: true
# frozen_string_literal: true

# The endpoint for the print terms of deposit window
class PrintController < ApplicationController
  def terms_of_deposit
    render layout: false
  end
end
