# frozen_string_literal: true

FactoryBot.define do
  factory :contact_email do
    email { "io@io.io" }
    emailable factory: %i[work]
  end
end
