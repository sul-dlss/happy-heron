# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :contributor do
    sequence :first_name do |n|
      "First#{n}"
    end

    sequence :last_name do |n|
      "Last#{n}"
    end

    work
    contributor_type { 'person' }
    role { 'Contributing author' }
  end
end
