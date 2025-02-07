# frozen_string_literal: true

# Base class for Deposit jobs.
class BaseDepositJob < ApplicationJob
  private

  def login
    SdrClientAuthenticator.login
  end
end
