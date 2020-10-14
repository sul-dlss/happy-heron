# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :related_link do
    link_title { 'My Awesome Research' }
    url { 'http://my.awesome.research.io' }
    work
  end
end
