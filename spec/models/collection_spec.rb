# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection do
  subject(:collection) { create(:collection, :with_works) }

  # TODO: Test some or all of the model attributes? (e.g., name, release options, license information, managers...)?

  it 'has many works' do
    expect(collection.works).to all(be_a(Work))
  end

  it 'has a valid contact email' do
    collection.contact_email = 'notavalidemail'
    expect {collection.save!}.to raise_error(an_instance_of(ActiveRecord::RecordInvalid).and having_attributes(message: "Validation failed: Contact email is invalid"))
  end
end
