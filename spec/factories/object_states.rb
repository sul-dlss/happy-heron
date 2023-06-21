# frozen_string_literal: true

FactoryBot.define do
  trait :pending_approval do
    state { "pending_approval" }
  end

  trait :first_draft do
    state { "first_draft" }
  end

  trait :version_draft do
    state { "version_draft" }
  end

  trait :depositing do
    state { "depositing" }
  end

  trait :deposited do
    state { "deposited" }
    # druid { 'druid:bc123df4567' }
  end

  trait :rejected do
    state { "rejected" }

    # events { [build(:event, event_type: 'reject', description: 'Add something to make it pop.')] }
  end

  trait :decommissioned do
    state { "decommissioned" }
  end

  trait :new do
    state { "new" }
  end

  trait :fetch_globus_first_draft do
    state { "fetch_globus_first_draft" }
  end
end
