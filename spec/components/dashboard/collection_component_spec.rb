# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::CollectionComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }
  let(:collection) { create(:collection) }
  let(:user_with_groups) { UserWithGroups.new(user: user, groups: []) }
  let(:user) { create(:user) }
  let(:work_path) { Rails.application.routes.url_helpers.work_path(user.deposits.first) }

  before do
    allow(controller).to receive_messages(
      allowed_to?: false,
      current_user: user,
      user_with_groups: user_with_groups
    )
  end

  context 'with 4 works' do
    before do
      create_list(:work, 4, collection: collection, depositor: user)
    end

    it 'renders a table of works' do
      expect(rendered.css('.work-title a').map { |node| node['href'] }).to include work_path
      expect(rendered.css('div').to_html).not_to include 'See all deposits'
    end
  end

  context 'with 5 works' do
    before do
      create_list(:work, 5, collection: collection, depositor: user)
    end

    it 'renders an indication that more works exist' do
      expect(rendered.css('div').to_html).to include 'See all deposits'
    end
  end

  context 'with a work that has a druid' do
    before do
      create(:work, collection: collection, depositor: user, druid: 'druid:yq268qt4607')
    end

    it 'renders a link to purl' do
      expect(rendered.css('a').map { |node| node['href'] }).to include 'https://purl.stanford.edu/yq268qt4607'
    end
  end
end
