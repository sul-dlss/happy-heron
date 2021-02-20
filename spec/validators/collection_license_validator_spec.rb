# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionLicenseValidator do
  let(:validator) { described_class.new }
  let(:record) { CreateCollectionForm.new(collection: Collection.new, collection_version: CollectionVersion.new) }

  context 'when a valid default license is provided' do
    before do
      record.default_license = 'CC0-1.0'
      validator.validate(record)
    end

    it 'is valid' do
      expect(record.errors.where(:license)).to be_empty
    end
  end

  context 'when a bogus default license is provided' do
    before do
      record.default_license = 'CC42-x.y'
      validator.validate(record)
    end

    it 'is invalid' do
      expect(record.errors.where(:license).first.message).to eq(
        'Either a required license or a default license must be present'
      )
    end
  end

  context 'when a valid required license is provided' do
    before do
      record.required_license = 'MIT'
      validator.validate(record)
    end

    it 'is valid' do
      expect(record.errors.where(:license)).to be_empty
    end
  end

  context 'when a bogus required license is provided' do
    before do
      record.required_license = 'Apache-0.0'
      validator.validate(record)
    end

    it 'is invalid' do
      expect(record.errors.where(:license).first.message).to eq(
        'Either a required license or a default license must be present'
      )
    end
  end

  context 'when both required license and default license are unset' do
    before do
      validator.validate(record)
    end

    it 'is invalid' do
      expect(record.errors.where(:license).first.message).to eq(
        'Either a required license or a default license must be present'
      )
    end
  end
end
