# frozen_string_literal: true

FactoryBot.define do
  factory :mail_preference do
    wanted { false }
    email { 'MyString' }
    user { nil }
    collection { nil }
  end
end
