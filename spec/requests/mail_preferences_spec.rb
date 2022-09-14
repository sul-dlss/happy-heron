# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MailPreferences', type: :request do
  describe 'edit preferences' do
    let(:user) { create(:user) }
    let(:rendered) do
      Capybara::Node::Simple.new(response.body)
    end

    before do
      sign_in user
    end

    context 'when the user is a manager' do
      let(:collection) { create(:collection_version_with_collection, reviewed_by: [user]).collection }

      it 'shows the checkbox for the two preferences' do
        get edit_collection_mail_preferences_path(collection)
        expect(response).to have_http_status(:ok)
        expect(rendered).to have_selector('input[type=checkbox]', count: 2) # rubocop:disable RSpec/Capybara/SpecificMatcher
      end
    end

    context 'when the user is a reviewer' do
      let(:collection) { create(:collection_version_with_collection, managed_by: [user]).collection }

      it 'shows the checkbox for the six preferences' do
        get edit_collection_mail_preferences_path(collection)
        expect(response).to have_http_status(:ok)
        expect(rendered).to have_selector('input[type=checkbox]', count: 6) # rubocop:disable RSpec/Capybara/SpecificMatcher
      end
    end
  end

  describe 'save preferences' do
    let(:user) { create(:user) }
    let(:collection) { create(:collection, managed_by: [user]) }
    let(:rendered) do
      Capybara::Node::Simple.new(response.body)
    end

    before do
      sign_in user
    end

    it 'shows the checkbox for each preference' do
      patch collection_mail_preferences_path(collection),
            params: { participant_changed: 'true', item_deleted: 'true' }
      expect(response).to have_http_status(:found)
      expect(collection.opted_out_of_email?(user, 'item_deleted')).to be false
      expect(collection.opted_out_of_email?(user, 'version_started_but_not_finished')).to be true
    end
  end
end
