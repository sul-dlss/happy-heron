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
  end

  trait :rejected do
    state { 'rejected' }
    events { [build(:event, event_type: 'rejected', description: 'Add something to make it pop.')] }
  end
end
