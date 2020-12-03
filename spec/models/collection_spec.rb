# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  subject(:collection) { build(:collection, :with_works) }

  it 'has many works' do
    expect(collection.works).to all(be_a(Work))
  end

  it 'has a valid contact email' do
    collection.contact_email = 'notavalidemail'
    expect { collection.save! }.to raise_error(ActiveRecord::RecordInvalid, /Contact email is invalid/)
  end

  describe '#purl' do
    context 'with a druid' do
      it 'constructs purl' do
        collection.update(druid: 'druid:hb093rg5848')
        expect(collection.purl).to eq('https://purl.stanford.edu/hb093rg5848')
      end
    end

    context 'with no druid' do
      it 'returns nil' do
        expect(collection.purl).to eq(nil)
      end
    end
  end
end
