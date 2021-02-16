# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :author do
    work_version

    factory :person_author do
      sequence :first_name do |n|
        "First#{n}"
      end

      sequence :last_name do |n|
        "Last#{n}"
      end

      contributor_type { 'person' }
      role { 'Contributing author' }
    end

    factory :org_author do
      sequence :full_name do |n|
        "organization#{n}"
      end
      contributor_type { 'organization' }
      role { 'Sponsor' }
    end
  end
end
