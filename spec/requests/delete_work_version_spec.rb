# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Deleting a version' do
  let(:work) { head_work_version.work }
  let(:head_version) { 1 }
  let(:user) { work.owner }

  before do
    work.update(head: head_work_version)
  end

  context 'when first version' do
    let(:head_work_version) { create(:work_version, state: :version_draft, version: head_version) }

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
    let(:head_version) { 2 }

    before do
      sign_in user, groups: ['dlss:hydrus-app-collection-creators']
    end

    context 'when the first version has a user version' do
      let(:head_work_version) { create(:work_version, state: :version_draft, user_version: 2, version: head_version) }
      let!(:first_version) { create(:work_version, user_version: 1, version: 1, work:) }

      it 'deletes the work version and changes version head' do
        delete "/work_versions/#{head_work_version.id}"

        expect(Work.find_by(id: work.id).head).to eq(first_version)
        expect(Work.find_by(id: work.id).head.user_version).to eq(1)
        expect(WorkVersion.find_by(id: head_work_version.id)).to be_nil
      end
    end

    context 'when the first version does not have a user version' do
      let(:head_work_version) { create(:work_version, state: :version_draft, user_version: 2, version: head_version) }
      let!(:first_version) { create(:work_version, user_version: nil, version: 1, work:) }

      it 'deletes the work version and changes version head' do
        delete "/work_versions/#{head_work_version.id}"

        expect(Work.find_by(id: work.id).head).to eq(first_version)
        expect(Work.find_by(id: work.id).head.user_version).to eq(2)
        expect(WorkVersion.find_by(id: head_work_version.id)).to be_nil
      end
    end
  end
end
