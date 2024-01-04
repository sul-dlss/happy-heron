# frozen_string_literal: true

FactoryBot.define do
  factory :related_link do
    link_title { 'My Awesome Research' }
    url { 'http://my.awesome.research.io' }
    linkable { nil }
  end

  trait :untitled do
    link_title { nil }
    url { 'https://your.awesome.research.ai' }
    linkable { nil }
  end
end
