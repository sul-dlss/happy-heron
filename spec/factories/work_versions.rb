# frozen_string_literal: true

FactoryBot.define do
  factory :work_version do
    sequence :title do |n|
      "Test title #{n}"
    end
    work_type { 'text' }
    subtype { ['Code', 'Oral history'] } # Subtype values intentionally include an item with whitespace
    abstract { 'test abstract' }
    citation { 'test citation' }
    license { 'CC0-1.0' }
    access { 'world' }
    state { 'first_draft' }
    description { 'initial version' }
    published_at { Time.zone.parse('2019-01-01') }
    work

    factory :valid_work_version do
      with_required_associations

      factory :valid_deposited_work_version do
        deposited
      end

      factory :work_version_with_work do
        transient do
          collection { nil }
          owner { association(:user) }
        end
        work { association :work, collection: collection, owner: owner }

        after(:create) do |work_version, _evaluator|
          work_version.work.update(head: work_version)
        end
      end
    end
  end

  trait :published do
    published_edtf { EDTF.parse('2020-02-14') }
  end

  trait :published_with_year_only do
    published_edtf { EDTF.parse('2021') }
  end

  trait :published_with_year_month_only do
    published_edtf { EDTF.parse('2021-04') }
  end

  trait :embargoed do
    embargo_date { 30.months.from_now }
  end

  trait :with_required_associations do
    with_keywords
    with_authors
    with_contact_emails
  end

  trait :with_creation_date_range do
    created_edtf { EDTF.parse('2020-03-04/2020-10-31') }
  end

  trait :with_approximate_creation_date_range do
    created_edtf { EDTF.parse('2020-03-04?/2020-10-31?') }
  end

  trait :with_creation_date do
    created_edtf { EDTF.parse('2020-03-08') }
  end

  trait :with_creation_date_year_only do
    created_edtf { EDTF.parse('2020') }
  end

  trait :with_creation_date_year_month_only do
    created_edtf { EDTF.parse('2020-06') }
  end

  trait :with_approximate_creation_date do
    created_edtf { EDTF.parse('2020-03-08?') }
  end

  trait :with_approximate_creation_date_year_only do
    created_edtf { EDTF.parse('2020?') }
  end

  trait :with_approximate_creation_date_year_month_only do
    created_edtf { EDTF.parse('2020-06?') }
  end

  trait :with_keywords do
    transient do
      keywords_count { 3 }
    end

    keywords { build_list(:keyword, keywords_count) }
  end

  trait :with_authors do
    transient do
      author_count { 3 }
    end

    authors { Array.new(author_count) { association(:person_author) } }
  end

  trait :with_contact_emails do
    transient do
      contact_emails_count { 1 }
    end

    contact_emails { Array.new(contact_emails_count) { association(:contact_email) } }
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

  trait :purl_reserved do
    work_type { WorkType.purl_reservation_type.id }
    subtype { [] }
    abstract { '' }
    citation { nil }
    license { 'none' }
    state { 'purl_reserved' }
  end

  trait :reserving_purl do
    work_type { WorkType.purl_reservation_type.id }
    subtype { [] }
    abstract { '' }
    citation { nil }
    license { 'none' }
    state { 'reserving_purl' }
  end

  trait :with_work do
    transient do
      collection { nil }
      owner { association(:user) }
    end
    work { association :work, collection: collection, owner: owner, work_versions: [instance] }

    after(:create) do |work_version, _evaluator|
      work_version.work.update(head: work_version)
    end
  end
end
