# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    title { 'Test title' }
    work_type { 'text' }
    subtype { ['Article', 'Presentation slides'] } # Subtype values intentionally include an item with whitespace
    contact_email { 'io@io.io' }
    abstract { 'test abstract' }
    citation { 'test citation' }
    license { 'CC0-1.0' }
    depositor { association(:user) }
    collection
  end

  trait :published do
    published_edtf { '2020-02-14' }
  end

  trait :with_creation_dates do
    created_edtf { '2020-03-04/2020-10-31' }
  end

  trait :with_keywords do
    transient do
      keywords_count { 3 }
    end

    keywords { Array.new(keywords_count) { association(:keyword) } }
  end

  trait :with_contributors do
    transient do
      contributors_count { 3 }
    end

    contributors { Array.new(contributors_count) { association(:contributor) } }
  end

  trait :with_related_links do
    transient do
      related_links_count { 2 }
    end

    related_links { Array.new(related_links_count) { association(:related_link) } }
  end

  trait :with_related_works do
    transient do
      related_works_count { 2 }
    end

    related_works { Array.new(related_works_count) { association(:related_work) } }
  end

  trait :with_attached_file do
    after(:build) do |work|
      create(:attached_file, :with_file, work: work)
    end
  end
end
