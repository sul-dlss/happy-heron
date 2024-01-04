# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Selecting a radio button causes other radio button inputs to be disabled', :js do
  let(:user) { create(:user) }

  before do
    sign_in user, groups: ['dlss:hydrus-app-administrators']
  end

  context 'with collection form' do
    describe 'release option' do
      let(:collection) { create(:collection, managed_by: [user], release_option: 'depositor-selects') }

      before do
        create(:collection_version_with_collection, :version_draft, collection:)
        visit edit_collection_path(collection)
      end

      it 'shows only one release option as checked and disables child select elements of other options' do
        delayed_release = find_by_id('collection_delay_release_duration')
        depositor_selects = find_by_id('collection_depositor_selects_release_duration')

        expect(find_by_id('collection_release_option_immediate')).not_to be_checked
        expect(find_by_id('collection_release_option_delay')).not_to be_checked
        expect(find_by_id('collection_release_option_depositor-selects')).to be_checked
        expect(delayed_release).to be_disabled
        expect(depositor_selects).not_to be_disabled

        # Disable "depositor-selects" select when "delay" selected
        choose('Delay release')
        expect(find_by_id('collection_release_option_immediate')).not_to be_checked
        expect(find_by_id('collection_release_option_delay')).to be_checked
        expect(find_by_id('collection_release_option_depositor-selects')).not_to be_checked
        expect(delayed_release).not_to be_disabled
        expect(depositor_selects).to be_disabled

        # When depositor_selects was clicked, it should have disabled the delay selection
        # Disable "depositor-selects" and "delay" selects when "immediately" selected
        choose('Immediately')
        expect(find_by_id('collection_release_option_immediate')).to be_checked
        expect(find_by_id('collection_release_option_delay')).not_to be_checked
        expect(find_by_id('collection_release_option_depositor-selects')).not_to be_checked
        expect(depositor_selects).to be_disabled
        expect(delayed_release).to be_disabled
      end
    end

    describe 'license option' do
      let(:collection) { create(:collection, managed_by: [user], license_option: 'required') }

      before do
        create(:collection_version_with_collection, :version_draft, collection:)
        visit edit_collection_path(collection)
      end

      it 'shows only one license option as checked and disables child select elements of other options' do
        expect(find_by_id('collection_license_option_required')).to be_checked
        expect(find_by_id('collection_license_option_depositor-selects')).not_to be_checked

        expect(find_by_id('collection_required_license')).not_to be_disabled
        expect(find_by_id('collection_default_license')).to be_disabled

        # Disable "required" select when "depositor-selects" selected
        choose('Depositor selects license')

        expect(find_by_id('collection_license_option_required')).not_to be_checked
        expect(find_by_id('collection_license_option_depositor-selects')).to be_checked

        expect(find_by_id('collection_required_license')).to be_disabled
        expect(find_by_id('collection_default_license')).not_to be_disabled

        # Disable "depositor-selects" select when "required" selected
        choose('Require license for all deposits')

        expect(find_by_id('collection_license_option_required')).to be_checked
        expect(find_by_id('collection_license_option_depositor-selects')).not_to be_checked

        expect(find_by_id('collection_required_license')).not_to be_disabled
        expect(find_by_id('collection_default_license')).to be_disabled
      end
    end
  end
end
