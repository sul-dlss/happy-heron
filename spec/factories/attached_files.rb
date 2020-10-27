# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :attached_file do
    label { 'MyString' }
    hide { false }
    work { nil }
  end

  trait :with_file do
    after(:build) do |work|
      # NOTE: alas, file_fixture methods don't work within FactoryBot
      work.file.attach(io: File.open(Rails.root.join('spec/fixtures/files/sul.svg')),
                       filename: 'sul.svg',
                       content_type: 'image/svg+xml')
    end
  end
end
