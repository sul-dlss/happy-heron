# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorkSubtypeValidator do
  let(:error_message) { "Subtype is not a valid subtype for work type #{work_type_id}" }
  let(:record) { WorkForm.new(work: build(:work), work_version:) }
  let(:validator) { described_class.new({attributes: ["stub"]}) }
  let(:work_version) { build(:work_version, work_type: work_type_id) }

  before do
    validator.validate_each(record, :subtype, value)
  end

  ["text", "data", "software, multimedia", "image", "sound", "video"].each do |work_type_id|
    context "with a type requiring no subtypes (#{work_type_id.inspect})" do
      let(:work_type_id) { work_type_id }

      context "without subtypes" do
        let(:value) { [] }

        it "validates" do
          expect(record.errors).to be_empty
        end
      end

      context 'with one or more valid "more" types' do
        let(:value) { ["Technical report", "MIDI", "Map"] }

        it "validates" do
          expect(record.errors).to be_empty
        end
      end

      context "with one or more bogus subtypes" do
        let(:value) { ["Foobar"] }

        it "fails to validate" do
          expect(record.errors.full_messages.first).to eq(error_message)
        end
      end
    end
  end

  context 'with a type requiring two subtypes ("mixed material")' do
    let(:work_type_id) { "mixed material" }

    context "with two valid subtypes" do
      let(:value) { %w[Data CAD] }

      it "validates" do
        expect(record.errors).to be_empty
      end
    end

    context 'with two valid subtypes and one or more valid "more" types' do
      let(:value) { %w[Data Speech Preprint] }

      it "validates" do
        expect(record.errors).to be_empty
      end
    end

    context 'with two valid subtypes and one or more bogus "more" types' do
      let(:value) { %w[Data Sound Foobar] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end

    context "with one valid and one bogus subtype" do
      let(:value) { %w[Data Foobar] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end

    context "with two or more bogus subtypes" do
      let(:value) { %w[Foo Bar] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end

    context "with a single valid subtype" do
      let(:value) { %w[Data] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end

    context "without subtypes" do
      let(:value) { [] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end
  end

  context 'with a type requiring one subtype ("music")' do
    let(:work_type_id) { "music" }

    context "with two valid subtypes" do
      let(:value) { %w[Data Sound] }

      it "validates" do
        expect(record.errors).to be_empty
      end
    end

    context 'with two valid subtypes and one or more valid "more" types' do
      let(:value) { %w[Data Sound Preprint] }

      it "validates" do
        expect(record.errors).to be_empty
      end
    end

    context 'with two valid subtypes and one or more bogus "more" types' do
      let(:value) { %w[Data Sound Foobar] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end

    context "with one valid and one bogus subtype" do
      let(:value) { %w[Data Foobar] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end

    context "with two or more bogus subtypes" do
      let(:value) { %w[Foo Bar] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end

    context "with a single valid subtype" do
      let(:value) { %w[Data] }

      it "validates" do
        expect(record.errors).to be_empty
      end
    end

    context "without subtypes" do
      let(:value) { [] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end
  end

  context 'with a type requiring at least one user-entered subtype ("other")' do
    let(:work_type_id) { "other" }

    context "with two subtypes" do
      let(:value) { %w[Anything Cool] }

      it "validates" do
        expect(record.errors).to be_empty
      end
    end

    context "with one subtype" do
      let(:value) { %w[Data] }

      it "validates" do
        expect(record.errors).to be_empty
      end
    end

    context "without subtypes" do
      let(:value) { [] }

      it "fails to validate" do
        expect(record.errors.full_messages.first).to eq(error_message)
      end
    end
  end
end
