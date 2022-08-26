# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Link to edit a work' do
  before do
    sign_in user
  end

  let(:collection) { create(:collection) }
  let(:rendered) do
    Capybara::Node::Simple.new(response.body)
  end
  let(:user) { create(:user) }

  context 'with a user who may edit the object' do
    let(:work) { create(:work_version_with_work, :version_draft, collection: collection, owner: user).work }

    it 'draws a link' do
      get "/works/#{work.id}/edit_button"
      expect(response).to have_http_status(:ok)
      expect(rendered).to have_selector('turbo-frame a span.fa-pencil-alt')
    end

    context 'when the work is locked' do
      before do
        work.update(locked: true)
      end

      it 'draws a lock' do
        get "/works/#{work.id}/edit_button"
        expect(response).to have_http_status(:ok)
        expect(rendered).to have_selector('turbo-frame a span.fa-lock')
      end
    end
  end

  context 'with a user who may not edit the object' do
    let(:work) { create(:work_version_with_work, :version_draft, collection: collection).work }

    it 'only draws the turbo-frame' do
      get "/works/#{work.id}/edit_button"
      expect(response).to have_http_status(:ok)
      expect(rendered).to have_selector('turbo-frame')
      expect(rendered).not_to have_link
    end
  end
end
