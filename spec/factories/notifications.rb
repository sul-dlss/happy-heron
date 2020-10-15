# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    opened_at { nil }
    text { 'There is a notifcation for the user' }
    user
  end

  trait :already_opened do
    opened_at { Time.current }
  end
end
