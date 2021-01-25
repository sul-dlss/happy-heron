# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Selecting a radio button causes other radio button inputs to be disabled', js: true do
  let(:user) { create(:user) }

  before do
    sign_in user, groups: ['dlss:hydrus-app-administrators']
  end

  context 'with collection form' do
    let(:collection) { create(:collection, managers: [user], release_option: 'depositor-selects') }

    before { visit edit_collection_path(collection) }

    it 'shows only one release option as checked and disables child select elements of other options' do
      expect(find('#collection_release_option_immediate')).not_to be_checked
      expect(find('#collection_release_option_delay')).not_to be_checked
      expect(find('#collection_release_option_depositor-selects')).to be_checked

      expect(find('#collection_release_duration')).not_to be_disabled

      expect(find('#collection_release_date_year')).to be_disabled
      expect(find('#collection_release_date_month')).to be_disabled
      expect(find('#collection_release_date_day')).to be_disabled

      # Disable "depositor-selects" select when "delay" selected
      choose('Delay release until')

      expect(find('#collection_release_option_immediate')).not_to be_checked
      expect(find('#collection_release_option_delay')).to be_checked
      expect(find('#collection_release_option_depositor-selects')).not_to be_checked

      expect(find('#collection_release_duration')).to be_disabled

      expect(find('#collection_release_date_year')).not_to be_disabled
      expect(find('#collection_release_date_month')).not_to be_disabled
      expect(find('#collection_release_date_day')).not_to be_disabled

      # Disable "depositor-selects" and "delay" selects when "immediately" selected
      choose('Immediately')

      expect(find('#collection_release_option_immediate')).to be_checked
      expect(find('#collection_release_option_delay')).not_to be_checked
      expect(find('#collection_release_option_depositor-selects')).not_to be_checked

      expect(find('#collection_release_duration')).to be_disabled

      expect(find('#collection_release_date_year')).to be_disabled
      expect(find('#collection_release_date_month')).to be_disabled
      expect(find('#collection_release_date_day')).to be_disabled
    end
  end
end
