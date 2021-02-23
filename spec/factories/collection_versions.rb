# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :collection_version do
    name { 'MyString' }
    description { 'MyString' }
    state { 'first_draft' }
    collection

    factory :collection_version_with_collection do
      transient do
        depositors { [] }
      end
      state { 'deposited' }
      collection { association :collection, depositors: depositors }

      after(:create) do |collection_version, _evaluator|
        collection_version.collection.update(head: collection_version)
      end
    end
  end
end
