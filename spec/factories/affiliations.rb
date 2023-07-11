# frozen_string_literal: true

FactoryBot.define do
  factory :affiliation do
    sequence(:label) { |n| "Affiliation #{n}" }

    trait :with_ror do
      sequence(:uri) { |n| "https://ror.org/#{n}" }
    end

    trait :with_department do
      sequence(:department) { |n| "Department #{n}" }
    end
  end
end
