# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :collection_version do
    name { 'MyString' }
    description { 'MyString' }
    state { 'first_draft' }
    collection
  end
end
