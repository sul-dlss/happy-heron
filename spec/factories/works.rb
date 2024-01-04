# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    depositor { association(:user) }
    owner { association(:user) }
    head { nil }
    created_at { Time.zone.parse('2007-02-10 15:30:45') }
    assign_doi { false }
    collection
  end

  trait :with_druid do
    druid { 'druid:bc123df4567' }
  end

  trait :with_doi do
    assign_doi { true }
    doi { '10.25740/hs561fr1234' }
  end

  trait :locked do
    locked { true }
  end
end
