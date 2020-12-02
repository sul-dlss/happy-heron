# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    description { 'MyString' }
    event_type { 'update_metadata' }
    eventable { nil }
    user
  end
end
