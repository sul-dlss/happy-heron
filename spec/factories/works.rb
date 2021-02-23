# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    depositor { association(:user) }
    head { nil }
    collection
  end

  trait :with_druid do
    druid { 'druid:bc123df4567' }
  end
end
