# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orcid do
  describe 'REGEX' do
    it 'returns valid' do
      expect(valid?('https://orcid.org/0000-0003-1527-0030')).to be true
      expect(valid?('https://orcid.org/0000-0003-1527-003X')).to be true
      expect(valid?('https://sandbox.orcid.org/0000-0003-1527-003X')).to be true
    end

    it 'returns invalid' do
      expect(valid?('https://orcid.org/0000-0003-1527-003Y')).to be false
      expect(valid?('0000-0003-1527-0030')).to be false
    end
  end

  def valid?(orcid_id)
    Orcid::REGEX.match(orcid_id).present?
  end
end
