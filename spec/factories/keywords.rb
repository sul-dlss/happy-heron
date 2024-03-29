# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :keyword do
    work_version { nil }
    label { "#{Faker::Food.spice} #{Faker::Food.ingredient}" }
    uri { 'http://example.org/uri' }
    cocina_type { 'place' }
  end

  trait :fixed_value do
    label { 'Ability--Testing' }
    uri { 'http://example.org/uri/testing' }
  end
end
