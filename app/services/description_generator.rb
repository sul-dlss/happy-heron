# typed: strict
# frozen_string_literal: true

# This generates a RequestDRO Description for a work
class DescriptionGenerator
  extend T::Sig

  sig { params(work: Work).returns(T::Hash[Symbol, T::Array[T::Hash[String, T.untyped]]]) }
  def self.generate(work:)
    new(work: work).generate
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  sig { returns(T::Hash[Symbol, T::Array[T::Hash[String, T.untyped]]]) }
  def generate
    {
      title: title,
      subject: keywords,
      note: [abstract, citation, contact],
      event: [created_date, published_date].compact
    }
  end

  private

  sig { returns(Work) }
  attr_reader :work

  sig { returns(T::Array[T::Hash[String, String]]) }
  def title
    [
      {
        "value": work.title
      }
    ]
  end

  sig { returns(T::Array[T::Hash[String, String]]) }
  def keywords
    work.keywords.map do |keyword|
      {
        "value": keyword.label,
        "type": 'topic'
      }
    end
  end

  sig { returns(T::Hash[String, String]) }
  def abstract
    {
      "value": work.abstract,
      "type": 'summary'
    }
  end

  sig { returns(T::Hash[String, String]) }
  def citation
    {
      "value": work.citation,
      "type": 'preferred citation'
    }
  end

  sig { returns(T.nilable(T::Hash[String, T.any(String, T::Array[T.untyped])])) }
  def created_date
    return unless work.created_edtf

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

  sig { returns(T.nilable(T::Hash[String, T.any(String, T::Array[T.untyped])])) }
  def published_date
    return unless work.published_edtf

    {
      "type": 'publication',
      "date": [
        {
          "value": work.published_edtf,
          "encoding": {
            "code": 'edtf'
          }
        }
      ]
    }
  end

  sig { returns(T::Hash[String, String]) }
  def contact
    {
      "value": work.contact_email,
      "type": 'contact',
      "displayLabel": 'Contact'
    }
  end
end
