# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    description { 'MyString' }
    event_type { 'MyString' }
    work { nil }
    user
  end
end
