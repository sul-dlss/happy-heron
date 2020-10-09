# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :work do
    title { 'Test title' }
    work_type { 'Book' }
    subtype { 'Non-fiction' }
    contact_email { 'io@io.io' }
    created_etdf { '1900' }
    abstract { 'test abstract' }
    citation { 'test citation' }
    access { 'stanford' }
    license { 'cc-0' }
    collection
  end
end
