# frozen_string_literal: true

FactoryBot.define do
  factory :attached_file do
    label { 'MyString' }
    hide { false }
    path { nil }
    work_version
  end

  trait :with_file do
    file { fixture_file_upload(Rails.root.join('spec/fixtures/files/sul.svg'), 'image/svg+xml') }
  end

  trait :with_path do
    path { 'images/sul.svg' }
  end
end
