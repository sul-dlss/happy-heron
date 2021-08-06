# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Deleting a version' do
  let(:work) { head_work_version.work }
  let(:head_work_version) { create(:work_version, state: :version_draft, version: head_version) }
  let(:head_version) { 1 }

  before do
    work.update(head: head_work_version)
  end

  context 'when first version' do
    let(:user) { work.depositor }

    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    it 'deletes the work and work version' do
      delete "/work_versions/#{head_work_version.id}"

      expect(Work.find_by(id: work.id)).to be_nil
      expect(WorkVersion.find_by(id: head_work_version.id)).to be_nil
    end
  end

  context 'when a subsequent version' do
    let(:user) { work.depositor }
    let(:head_version) { 2 }
    let!(:first_version) { create(:work_version, version: 1, work: work) }

    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    it 'deletes the work version and changes version head' do
      delete "/work_versions/#{head_work_version.id}"

      expect(Work.find_by(id: work.id).head).to eq(first_version)
      expect(WorkVersion.find_by(id: head_work_version.id)).to be_nil
    end
  end
end
