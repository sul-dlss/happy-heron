# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    sequence :title do |n|
      "Test title #{n}"
    end
    work_type { 'text' }
    subtype { ['Article', 'Government document'] } # Subtype values intentionally include an item with whitespace
    contact_email { 'io@io.io' }
    abstract { 'test abstract' }
    citation { 'test citation' }
    license { 'CC0-1.0' }
    depositor { association(:user) }
    access { 'world' }
    state { 'first_draft' }
    collection

    factory :valid_work do
      with_required_associations

      factory :valid_deposited_work do
        deposited
      end
    end
  end

  trait :published do
    published_edtf { EDTF.parse('2020-02-14') }
  end

  trait :embargoed do
    embargo_date { 30.months.from_now }
  end

  trait :with_required_associations do
    with_keywords
    with_contributors
    with_attached_file
  end

  trait :with_creation_date_range do
    created_edtf { EDTF.parse('2020-03-04/2020-10-31') }
  end

  trait :with_creation_date do
    created_edtf { EDTF.parse('2020-03-08') }
  end

  trait :with_keywords do
    transient do
      keywords_count { 3 }
    end

    keywords { build_list(:keyword, keywords_count) }
  end

  trait :with_contributors do
    transient do
      contributors_count { 3 }
    end

    contributors { Array.new(contributors_count) { association(:person_contributor) } }
  end

  trait :with_related_links do
    transient do
      related_links_count { 2 }
    end

    related_links { Array.new(related_links_count) { association(:related_link) } }
  end

  trait :with_some_untitled_related_links do
    transient do
      related_links_count { 2 }
      untitled_related_links_count { 2 }
    end

    related_links do
      Array.new(related_links_count) { association(:related_link) } +
        Array.new(untitled_related_links_count) { association(:related_link, :untitled) }
    end
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
