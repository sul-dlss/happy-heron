# frozen_string_literal: true

FactoryBot.define do
  factory :collection do
    release_option { 'immediate' }
    access { 'world' }
    license_option { 'depositor-selects' }
    email_when_participants_changed { false }
    email_depositors_status_changed { false }
    review_enabled { false }
    allow_custom_rights_statement { false }
    creator
  end

  trait :with_required_license do
    required_license { 'CC-BY-4.0' }
    license_option { 'required' }
  end

  trait :with_default_license do
    default_license { 'CC-BY-4.0' }
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

    review_enabled { true }
    reviewed_by { build_list(:user, reviewer_count) }
  end

  trait :with_managers do
    transient do
      manager_count { 2 }
    end

    managed_by { build_list(:user, manager_count) }
  end

  trait :with_depositors do
    transient do
      depositor_count { 1 }
    end

    depositors { build_list(:user, depositor_count) }
  end

  trait :with_events do
    transient do
      event_count { 3 }
    end

    events { build_list(:event, event_count) }
  end

  trait :email_depositors_status_changed do
    email_depositors_status_changed { true }
  end

  trait :email_when_participants_changed do
    email_when_participants_changed { true }
  end

  trait :depositor_selects_access do
    access { 'depositor-selects' }
  end

  trait :depositor_selects_release_date do
    release_option { 'depositor-selects' }
    release_duration { '3 years' }
  end

  trait :with_collection_druid do
    druid { 'druid:dc224fz4940' }
  end

  trait :with_custom_rights_from_collection do
    allow_custom_rights_statement { true }
    provided_custom_rights_statement { 'An addendum to the built in terms of use' }
  end

  trait :with_custom_rights_from_depositor do
    allow_custom_rights_statement { true }
    provided_custom_rights_statement { nil }
  end

  trait :with_custom_rights_instructions_from_collection do
    allow_custom_rights_statement { true }
    provided_custom_rights_statement { nil }
    custom_rights_statement_custom_instructions do
      "Instructions you should follow about the terms you're allowed to enter"
    end
  end
end
