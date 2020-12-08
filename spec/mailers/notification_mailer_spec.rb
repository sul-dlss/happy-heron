# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  describe 'reject_email' do
    let(:user) { work.depositor }
    let(:mail) { described_class.with(user: user, work: work).reject_email }
    let(:work) { create(:work, :rejected) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit has been reviewed and returned'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the reason' do
      expect(mail.body.encoded).to match('Add something to make it pop.')
    end
  end

  describe 'approved_email' do
    let(:user) { work.depositor }
    let(:mail) { described_class.with(user: user, work: work).approved_email }
    let(:work) { create(:work, :deposited, title: 'Hammock kombucha mustache', collection: collection) }
    let(:collection) { build(:collection, :with_reviewers, name: 'Farm-to-table beard aesthetic') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit has been reviewed and approved'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the reason' do
      expect(mail.body.encoded).to have_content('“Hammock kombucha mustache”')
      expect(mail.body.encoded).to have_content('Farm-to-table beard aesthetic collection')
    end
  end

  describe 'submitted_for_review_email' do
    let(:user) { build(:user, name: 'Al Dente') }
    let(:mail) { described_class.with(user: user, work: work).submitted_for_review_email }
    let(:work) { build(:work, :pending_approval, collection: collection, depositor: user) }
    let(:collection) { build(:collection, :with_reviewers, name: 'small batch organic') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'A Depositor has submitted a deposit in the small batch organic collection'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the reason' do
      expect(mail.body.encoded).to match 'The Depositor Al Dente has submitted a ' \
        'deposit for review in the small batch organic collection.'
    end
  end
end
