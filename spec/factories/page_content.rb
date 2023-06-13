# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :page_content do
    page { 'home' }
    value { "#{Faker::Food.spice} #{Faker::Food.ingredient}" }
    visible { true }
  end
end
