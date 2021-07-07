# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReviewersMailer, type: :mailer do
  describe 'submitted_email' do
    let(:user) { build(:user, name: 'Al Dente') }
    let(:mail) { described_class.with(user: user, work_version: work_version).submitted_email }
    let(:work) { build(:work, collection: collection, depositor: user) }
    let(:work_version) { build_stubbed(:work_version, :pending_approval, work: work) }
    let(:collection) { build(:collection, :with_reviewers, head: collection_version) }
    let(:collection_version) { build(:collection_version, name: 'small batch organic') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'New deposit activity in the small batch organic collection'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the reason' do
      expect(mail.body.encoded).to match 'The Depositor Al Dente has submitted a ' \
                                         'deposit for review in the small batch organic collection.'
    end
  end
end
