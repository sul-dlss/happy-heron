# typed: false
# frozen_string_literal: true

FactoryBot.define do
  trait :pending_approval do
    state { 'pending_approval' }
  end

  trait :first_draft do
    state { 'first_draft' }
  end

  trait :version_draft do
    state { 'version_draft' }
  end

  trait :depositing do
    state { 'depositing' }
  end

  trait :deposited do
    state { 'deposited' }
    druid { 'druid:bc123df4567' }
  end

  trait :rejected do
    state { 'rejected' }

    after(:create) do |work|
      create(:event, event_type: 'reject', description: 'Add something to make it pop.', eventable: work)
    end
  end
end
