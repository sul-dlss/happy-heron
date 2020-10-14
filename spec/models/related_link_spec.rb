# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelatedLink do
  subject(:related_link) { create(:related_link, work: work) }

  let(:work) { create(:work) }

  it 'has a title' do
    expect(related_link.link_title).to be_present
  end

  it 'has a url' do
    expect(related_link.url).to be_present
  end

  it 'belongs to a work' do
    expect(related_link.work).to be_a(Work)
  end
end
