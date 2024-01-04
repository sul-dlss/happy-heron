# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    description { 'MyString' }
    event_type { 'update_metadata' }
    eventable { nil }
    user

    factory :embargo_lifted_event do
      event_type { 'embargo_lifted' }
      user { nil }
    end
  end
end
