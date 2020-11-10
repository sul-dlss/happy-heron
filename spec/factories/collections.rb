# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    name { 'MyString' }
    description { 'MyString' }
    contact_email { 'email@example.com' }
    release_option { 'MyString' }
    release_duration { 'MyString' }
    release_date { '2020-10-09' }
    access { 'MyString' }
    required_license { 'MyString' }
    default_license { 'MyString' }
    email_when_participants_changed { false }
    managers { 'maya.aguirre, jcairns' }
    creator
  end

  trait :with_works do
    transient do
      works_count { 2 }
    end

    works { Array.new(works_count) { association(:work) } }
  end

  trait :with_reviewers do
    transient do
      reviewer_count { 2 }
    end

    reviewers { build_list(:user, reviewer_count) }
  end
end
