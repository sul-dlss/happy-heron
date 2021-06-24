# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::CollectionComponent, type: :component do
  let(:rendered) { render_inline(described_class.new(collection: collection)) }
  let(:collection) { build_stubbed(:collection, head: collection_version) }
  let(:collection_version) { build_stubbed(:collection_version) }
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

  context 'with a new, first draft collection' do
    let(:collection_version) { build_stubbed(:collection_version, :first_draft) }

    it 'does not render the deposit button' do
      expect(rendered.to_html).not_to include '+ Deposit to this collection'
    end

    it 'does not render the PURL reservation button' do
      expect(rendered.to_html).not_to include 'Reserve a PURL'
    end
  end

  context 'with a collection currently in the process of depositing' do
    let(:collection_version) { build_stubbed(:collection_version, :depositing) }

    it 'does not render the deposit button' do
      expect(rendered.to_html).not_to include '+ Deposit to this collection'
    end

    it 'does not render the PURL reservation button' do
      expect(rendered.to_html).not_to include 'Reserve a PURL'
    end
  end

  context 'with a deposit ready collection' do
    it 'renders the turbo-frame that holds the deposit button' do
      expect(rendered.css("turbo-frame#deposit_collection_#{collection.id}").first['src']).to be_present
    end
  end

  context "when the works don't belong to the user" do
    let(:collection) { collection_version.collection }
    let(:collection_version) { create(:collection_version_with_collection) }

    before do
      create(:work_version_with_work, collection: collection, depositor: user, title: 'my work')
      create(:work_version_with_work, collection: collection, title: 'not mine')
    end

    context 'when the user is a depositor' do
      it 'renders a table with just my works' do
        expect(rendered.css('.work-title a').map(&:text)).to eq ['my work']
      end
    end

    context 'when the user is the collection manager' do
      let(:collection_version) { create(:collection_version_with_collection, managed_by: [user]) }

      it 'renders all of the works' do
        expect(rendered.css('.work-title a').map(&:text)).to eq ['not mine', 'my work']
      end
    end
  end

  context 'with 4 works' do
    let(:collection) { collection_version.collection }
    let(:collection_version) { create(:collection_version_with_collection) }

    before do
      4.times do
        work = create(:work, collection: collection, depositor: user)
        version = create(:work_version, work: work)
        work.update(head: version)
      end
    end

    it 'renders a table of works' do
      expect(rendered.css('.work-title a').map { |node| node['href'] }).to include work_path
      expect(rendered.css('div').to_html).not_to include 'See all deposits'
    end
  end

  context 'with 5 works' do
    let(:collection) { collection_version.collection }
    let(:collection_version) { create(:collection_version_with_collection) }

    before do
      5.times do
        work = create(:work, collection: collection, depositor: user)
        version = create(:work_version, work: work)
        work.update(head: version)
      end
    end

    it 'renders an indication that more works exist' do
      expect(rendered.css('div').to_html).to include 'See all deposits'
    end
  end

  context 'with a work that has a druid' do
    let(:collection) { collection_version.collection }
    let(:collection_version) { create(:collection_version_with_collection) }
    let(:work) { create(:work, collection: collection, depositor: user, druid: 'druid:yq268qt4607') }

    before do
      version = create(:work_version, work: work)
      work.update(head: version)
    end

    it 'renders a link to purl' do
      expect(rendered.css('a').map { |node| node['href'] }).to include 'http://purl.stanford.edu/yq268qt4607'
    end
  end
end
