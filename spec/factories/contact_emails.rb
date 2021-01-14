# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :contact_email do
    email { 'io@io.io' }
    association :emailable, factory: :work
  end
end
