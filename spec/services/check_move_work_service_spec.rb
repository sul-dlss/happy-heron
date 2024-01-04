# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckMoveWorkService do
  let(:errors) { described_class.check(work:, collection:) }

  let(:work) { build(:work, :with_doi) }
  let(:collection) { build(:collection, :with_druid) }
  let(:work_version) { create(:work_version, work:) }

  before do
    work.update(head: work_version)
  end

  context 'when work can be moved to collection' do
    it 'returns no errors' do
      expect(errors).to be_empty
    end
  end

  context 'when collection has not been deposited' do
    let(:collection) { build(:collection) }

    it 'returns an error' do
      expect(errors).to eq ['Collection has not been deposited.']
    end
  end

  context 'when work is already in collection' do
    before do
      work.collection = collection
    end

    it 'returns an error' do
      expect(errors).to eq ['Collection is the same as the current collection.']
    end
  end

  context 'when work is embargoed but collection is set for immediate release only' do
    let(:work_version) { create(:work_version, :embargoed, work:, state: 'deposited') }

    it 'returns an error' do
      expect(errors).to eq ['Item is embargoed but the collection is set for immediate release only.']
    end
  end

  context 'when work is not embargoed but collection is set for immediate release only' do
    let(:work_version) { create(:work_version, :expired_embargo, work:, state: 'deposited') }

    it 'returns no errors' do
      expect(errors).to eq []
    end
  end

  context 'when work is embargoed but collection is not set for immediate release only' do
    let(:work_version) { create(:work_version, :embargoed, work:, state: 'deposited') }
    let(:collection) { build(:collection, :with_druid, :depositor_selects_release_date) }

    it 'returns no errors' do
      expect(errors).to eq []
    end
  end

  context 'when DOI is required but work is not assigned DOI' do
    let(:work) { build(:work, assign_doi: false) }

    it 'returns an error' do
      expect(errors).to eq ['Depositor of the item chose not to get a DOI but the collection requires DOI assignment.']
    end
  end

  context 'when DOI is not required and work is not assigned a DOI' do
    let(:work) { build(:work, assign_doi: false) }

    before do
      collection.doi_option = 'depositor-selects'
    end

    it 'returns no errors' do
      expect(errors).to eq []
    end
  end

  context 'when collection requires a license but work has a different license' do
    let(:collection) { build(:collection, :with_druid, :with_required_license) }

    it 'returns an error' do
      expect(errors).to eq ['Item has a license that is not allowed by the collection setting.']
    end
  end

  context 'when collection requires a license and work has same license' do
    let(:collection) { build(:collection, :with_druid, :with_required_license) }

    before do
      work_version.license = collection.required_license
    end

    it 'returns no errors' do
      expect(errors).to eq []
    end
  end

  context 'when collection access is world but work access is stanford' do
    before do
      work_version.access = 'stanford'
    end

    it 'returns an error' do
      expect(errors).to eq ['Item is set for Stanford visibility but the collection requires world visibility.']
    end
  end

  context 'when collection access is depositor-selects and work access is stanford' do
    before do
      collection.access = 'depositor-selects'
    end

    it 'returns no errors' do
      expect(errors).to eq []
    end
  end
end
