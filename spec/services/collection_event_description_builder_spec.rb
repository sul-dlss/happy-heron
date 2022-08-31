# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionEventDescriptionBuilder do
  subject(:result) { described_class.build(form: form, change_set: change_set) }

  let(:collection) { create(:collection) }
  let(:form) { CollectionSettingsForm.new(collection) }
  let(:change_set) do
    instance_double(CollectionChangeSet,
                    participants_changed?: participants_changed,
                    participant_change_description: participant_change_description,
                    email_when_participants_changed_changed?: email_when_participants_changed_changed,
                    email_depositors_status_changed_changed?: email_depositors_status_changed_changed,
                    review_enabled_changed?: review_enabled_changed,
                    reviewers_changed?: reviewers_changed)
  end
  let(:participants_changed) { false }
  let(:participant_change_description) { nil }
  let(:email_when_participants_changed_changed) { false }
  let(:email_depositors_status_changed_changed) { false }
  let(:review_enabled_changed) { false }
  let(:reviewers_changed) { false }

  context 'when nothing has changed' do
    it { is_expected.to be_blank }
  end

  context 'when participants has changed' do
    let(:participants_changed) { true }
    let(:participant_change_description) { 'Added depositors: lstanford' }

    before do
      form.validate({})
    end

    it { is_expected.to eq 'Added depositors: lstanford' }
  end

  context 'when release settings has changed' do
    before do
      form.validate(release_option: 'delay', release_duration: '6 months')
    end

    it { is_expected.to eq 'release settings modified' }
  end

  context 'when release duration has changed' do
    before do
      collection.update(release_option: 'delay', release_duration: '6 months')
      form.validate(release_option: 'delay', release_duration: '1 year')
    end

    it { is_expected.to eq 'release settings modified' }
  end

  context 'when release settings has not changed' do
    before do
      form.validate(release_option: 'immediate')
    end

    it { is_expected.to eq '' }
  end

  context 'when download settings has changed' do
    before do
      form.validate(access: 'stanford')
    end

    it { is_expected.to eq 'download setting modified' }
  end

  context 'when download settings has not changed' do
    before do
      form.validate(access: 'world')
    end

    it { is_expected.to eq '' }
  end

  context 'when DOI settings has changed' do
    before do
      form.validate(doi_option: 'no')
    end

    it { is_expected.to eq 'DOI setting modified' }
  end

  context 'when DOI settings has not changed' do
    before do
      form.validate(doi_option: 'yes')
    end

    it { is_expected.to eq '' }
  end

  context 'when license options has changed' do
    before do
      collection.update(default_license: 'CC-BY-4.0')
      form.validate(license_option: 'required', default_license: 'Apache-2.0')
    end

    it { is_expected.to eq 'license settings modified' }
  end

  context 'when license options has not changed' do
    before do
      collection.update(default_license: 'CC-BY-4.0')
      form.validate(license_option: 'depositor-selects', default_license: 'CC-BY-4.0')
    end

    it { is_expected.to eq '' }
  end

  context 'when default license has changed' do
    before do
      collection.update(default_license: 'CC-BY-4.0')
      form.validate(license_option: 'depositor-selects', default_license: 'Apache-2.0')
    end

    it { is_expected.to eq 'license settings modified' }
  end

  context 'when required license has changed' do
    before do
      collection.update(license_option: 'required', required_license: 'CC-BY-4.0')
      form.validate(license_option: 'required', default_license: 'Apache-2.0')
    end

    it { is_expected.to eq 'license settings modified' }
  end

  context 'when notification settings has not changed' do
    before do
      form.validate({})
    end

    it { is_expected.to eq '' }
  end

  context 'when email when participants has changed' do
    let(:email_when_participants_changed_changed) { true }

    before do
      form.validate({})
    end

    it { is_expected.to eq 'notification settings modified' }
  end

  context 'when email when depositors status has changed' do
    let(:email_depositors_status_changed_changed) { true }

    before do
      form.validate({})
    end

    it { is_expected.to eq 'notification settings modified' }
  end

  context 'when review settings has changed' do
    let(:review_enabled_changed) { true }

    before do
      form.validate({})
    end

    it { is_expected.to eq 'review workflow settings modified' }
  end

  context 'when reviewers has changed' do
    let(:participants_changed) { true }
    let(:reviewers_changed) { true }
    let(:participant_change_description) { 'Added reviewers: lstanford' }

    before do
      form.validate({})
    end

    it { is_expected.to eq 'Added reviewers: lstanford, review workflow settings modified' }
  end
end
