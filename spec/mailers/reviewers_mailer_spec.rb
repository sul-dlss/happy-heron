# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewersMailer do
  describe 'submitted_email' do
    let(:user) { build(:user, name: 'Al Dente', first_name: 'Fred') }
    let(:mail) { described_class.with(user:, work_version:).submitted_email }
    let(:work) { build_stubbed(:work, collection:, depositor: user, owner: user) }
    let(:work_version) { build_stubbed(:work_version, :pending_approval, work:, title: 'Test title') }
    let(:collection) { build(:collection, :with_reviewers, head: collection_version) }
    let(:collection_version) { build(:collection_version, name: 'small batch organic') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Item ready for review in the small batch organic collection'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'salutation uses user.first_name' do
      expect(mail.body).to include("Dear #{user.first_name},")
      expect(mail.body).not_to include("Dear #{user.name},")
    end

    it 'renders the reason' do
      expect(mail.body.encoded).to match "The Depositor Al Dente has submitted the deposit \"Test title\" for\r\n  " \
                                         'review in the small batch organic collection.'
    end
  end
end
