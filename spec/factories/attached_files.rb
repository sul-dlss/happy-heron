# frozen_string_literal: true

FactoryBot.define do
  factory :attached_file do
    label { 'MyString' }
    hide { false }
    path { 'sul.svg' }
    work_version
  end

  trait :with_file do
    file { fixture_file_upload(Rails.root.join('spec/fixtures/files/sul.svg'), 'image/svg+xml') }
  end

  trait :with_preserved_file do
    with_file
    after(:build, &:transform_blob_to_preservation)
  end
end
