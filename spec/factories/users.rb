# frozen_string_literal: true

FactoryBot.define do
  factory :user, aliases: [:creator] do
    sequence :email do |n|
      "user#{n}-#{Time.zone.now.to_i}@stanford.edu"
    end

    # this ensures all new works created in tests will have the terms accepted by default
    # see https://github.com/sul-dlss/happy-heron/issues/243
    last_work_terms_agreement { Time.zone.now }
  end
end
