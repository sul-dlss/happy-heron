# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :attached_file do
    label { 'MyString' }
    hide { false }
    work
  end

  trait :with_file do
    file { fixture_file_upload(Rails.root.join('spec/fixtures/files/sul.svg'), 'image/svg+xml') }
  end
end
