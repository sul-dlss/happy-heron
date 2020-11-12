# typed: false
# frozen_string_literal: true

# Records events in the lifecycle of a deposit
class Event < ApplicationRecord
  belongs_to :work
  belongs_to :user
end
