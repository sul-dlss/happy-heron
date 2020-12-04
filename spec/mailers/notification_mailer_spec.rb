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

  describe 'deposited_email' do
    let(:user) { work.depositor }
    let(:mail) { described_class.with(user: user, work: work).deposited_email }
    let(:work) { create(:work, :deposited, title: 'Photo booth activated charcoal', collection: collection) }
    let(:collection) { build(:collection, name: 'gastropub humblebrag taiyaki') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your deposit, Photo booth activated charcoal, is published in the SDR'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content('“Photo booth activated charcoal”')
      expect(mail.body.encoded).to have_content('gastropub humblebrag taiyaki collection')
    end
  end

  describe 'new_version_deposited_email' do
    let(:user) { work.depositor }
    let(:mail) { described_class.with(user: user, work: work).new_version_deposited_email }
    let(:work) { create(:work, :deposited, title: 'twee retro man braid', collection: collection) }
    let(:collection) { build(:collection, name: 'listicle fam ramps flannel') }

    it 'renders the headers' do
      expect(mail.subject).to eq 'A new version of twee retro man braid has been deposited in the SDR'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to have_content('“twee retro man braid”')
      expect(mail.body.encoded).to have_content('listicle fam ramps flannel')
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

  describe 'invitation_to_deposit_email' do
    let(:user) { collection.depositors.first }
    let(:mail) { described_class.with(user: user, collection: collection).invitation_to_deposit_email }
    let(:collection) { create(:collection, :with_depositors) }

    it 'renders the headers' do
      expect(mail.subject).to eq "Invitation to deposit to the #{collection.name} collection in the SDR"
      expect(mail.to).to eq [collection.depositors.first.email]
      expect(mail.from).to eq ['no-reply@sdr.stanford.edu']
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match("You have been invited to deposit to the #{collection.name} collection")
    end
  end
end
