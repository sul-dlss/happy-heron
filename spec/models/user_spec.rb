# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject(:user) { build(:user) }

  context 'when email not provided' do
    let(:invalid_user) { described_class.new }

    it 'validates email is present' do
      expect(invalid_user).not_to be_valid
      expect(invalid_user.errors.messages.to_h).to include(email: ["can't be blank"])
    end
  end

  context 'when email is invalid' do
    let(:invalid_user) { described_class.new(email: 'jcoyne85@stanford.edu@stanford.edu') }

    it 'validates email is correct' do
      expect(invalid_user).not_to be_valid
      expect(invalid_user.errors.messages.to_h).to include(email: ['must be a valid email address'])
    end
  end

  context 'when email is already used' do
    before { user.save! }

    let(:invalid_user) { described_class.new(email: user.email) }

    it 'validates email is unique' do
      expect(invalid_user).not_to be_valid
      expect(invalid_user.errors.messages.to_h).to include(email: ['has already been taken'])
    end
  end

  it 'uses email as string representation' do
    expect(user.to_s).to eq(user.email)
  end
end
