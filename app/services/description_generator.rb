# typed: true
# frozen_string_literal: true

# This generates a RequestDRO Description for a work
class DescriptionGenerator
  extend T::Sig

  sig { params(work: Work).returns(Hash) }
  def self.generate(work:)
    new(work: work).generate
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  sig { returns(Hash) }
  def generate
    {
      title: title,
      # TODO: keywords not yet in model.
      note: [abstract, citation, contact],
      event: [created_date]
    }
  end

  private

  attr_reader :work

  def title
    [
      {
        "value": work.title
      }
    ]
  end

  def abstract
    {
      "value": work.abstract,
      "type": 'summary'
    }
  end

  def citation
    {
      "value": work.citation,
      "type": 'preferred citation'
    }
  end

  # rubocop:disable Metrics/MethodLength
  def created_date
    {
      "type": 'creation',
      "date": [
        {
          "value": work.created_edtf,
          "encoding": {
            "code": 'edtf'
          }
        }
      ]
    }
  end
  # rubocop:enable Metrics/MethodLength

  def contact
    {
      "value": work.contact_email,
      "type": 'contact',
      "displayLabel": 'Contact'
    }
  end
end
