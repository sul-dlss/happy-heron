# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:creator] do
    sequence :email do |n|
      "user#{n}@stanford.edu"
    end
  end
end
