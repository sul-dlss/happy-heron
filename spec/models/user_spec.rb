# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject(:user) { create(:user) }

  context 'when email not provided' do
    let(:invalid_user) { described_class.new }

    it 'validates email is present' do
      expect(invalid_user).not_to be_valid
      expect(invalid_user.errors.messages).to include(email: ["can't be blank"])
    end
  end

  context 'when email is already used' do
    let(:invalid_user) { described_class.new(email: user.email) }

    it 'validates email is unique' do
      expect(invalid_user).not_to be_valid
      expect(invalid_user.errors.messages).to include(email: ['has already been taken'])
    end
  end

  context 'with notifications' do
    let(:notification) { create(:notification, user: user) }

    it 'has notifications' do
      expect(user.notifications).to include(notification)
    end
  end

  it 'uses email as string representation' do
    expect(user.to_s).to eq(user.email)
  end
end
