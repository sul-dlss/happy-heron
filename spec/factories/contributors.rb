# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :contributor do
    work

    factory :person_contributor do
      sequence :first_name do |n|
        "First#{n}"
      end

      sequence :last_name do |n|
        "Last#{n}"
      end

      contributor_type { 'person' }
      role { 'Contributing author' }
    end

    factory :org_contributor do
      sequence :full_name do |n|
        "organization#{n}"
      end
      contributor_type { 'organization' }
      role { 'Sponsor' }
    end
  end
end
