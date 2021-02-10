# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :keyword do
    work_version { nil }
    label { 'MyString' }
    uri { 'MyString' }
  end
end
