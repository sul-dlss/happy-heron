# frozen_string_literal: true

FactoryBot.define do
  factory :keyword do
    work_version { nil }
    label { 'MyKeyword' }
    uri { 'http://example.org/uri' }
  end
end
