# frozen_string_literal: true

FactoryBot.define do
  factory :collection_version do
    name { "MyString" }
    description { "MyString" }
    state { "first_draft" }
    collection

    trait :with_version_description do
      version_description { "really important changes" }
    end

    factory :collection_version_with_collection do
      transient do
        depositors { [] }
        reviewed_by { [] }
        managed_by { [] }
        review_enabled { false }
        access { "world" }
        doi_option { "no" }
        collection_druid { nil }
      end
      state { "deposited" }
      collection do
        association(:collection, depositors:,
          managed_by:,
          reviewed_by:,
          review_enabled:,
          doi_option:,
          access:,
          druid: collection_druid)
      end

      after(:create) do |collection_version, _evaluator|
        collection_version.collection.update(head: collection_version)
      end

      after(:build) do |collection_version, _evaluator|
        collection_version.collection.head = collection_version
      end
    end
  end
end
