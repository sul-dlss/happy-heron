# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :version do
    description { 'MyText' }
    versionable { nil }
  end
end
