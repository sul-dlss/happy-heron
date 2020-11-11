# typed: strict
# frozen_string_literal: true

# This generates a RequestDRO Description for a work
# rubocop:disable Metrics/ClassLength
class DescriptionGenerator
  extend T::Sig

  STRING_HASH_TYPE = T.type_alias { T::Hash[String, String] }
  STRING_HASH_ARRAY_TYPE = T.type_alias { T::Array[STRING_HASH_TYPE] }
  NILABLE_DATE_TYPE = T.type_alias do
    T.nilable({ type: String, date: T::Array[{ value: T.nilable(String), encoding: { code: String } }] })
  end
  COCINA_DESCRIPTION_TYPE = T.type_alias do
    {
      title: STRING_HASH_ARRAY_TYPE,
      contributor: T::Array[T::Array[Object]],
      subject: STRING_HASH_ARRAY_TYPE,
      note: [STRING_HASH_TYPE, STRING_HASH_TYPE, STRING_HASH_TYPE],
      event: T::Array[NILABLE_DATE_TYPE],
      relatedResource: T::Array[T.any(RelatedLink::COCINA_HASH_TYPE, RelatedWork::COCINA_HASH_TYPE)]
    }
  end

  sig { params(work: Work).returns(COCINA_DESCRIPTION_TYPE) }
  def self.generate(work:)
    new(work: work).generate
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  sig { returns(COCINA_DESCRIPTION_TYPE) }
  def generate
    {
      title: title,
      contributor: contributors,
      subject: keywords,
      note: [abstract, citation, contact],
      event: [created_date, published_date].compact,
      relatedResource: related_links + related_works
    }
  end

  private

  sig { returns(Work) }
  attr_reader :work

  sig { returns(STRING_HASH_ARRAY_TYPE) }
  def title
    [
      {
        "value": work.title
      }
    ]
  end

  sig { returns(STRING_HASH_ARRAY_TYPE) }
  def keywords
    work.keywords.map do |keyword|
      {
        "value": keyword.label,
        "type": 'topic'
      }
    end
  end

  sig { returns(STRING_HASH_TYPE) }
  def abstract
    {
      "value": work.abstract,
      "type": 'summary'
    }
  end

  sig { returns(STRING_HASH_TYPE) }
  def citation
    {
      "value": work.citation,
      "type": 'preferred citation'
    }
  end

  sig { returns(NILABLE_DATE_TYPE) }
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

  sig { returns(NILABLE_DATE_TYPE) }
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

  sig { returns(STRING_HASH_TYPE) }
  def contact
    {
      "value": work.contact_email,
      "type": 'contact',
      "displayLabel": 'Contact'
    }
  end

  sig { returns(T::Array[T::Array[Object]]) }
  def contributors
    result = []

    work.contributors.each do |work_form_contributor|
      result << contributor(work_form_contributor)
    end

    result
  end

  # in cocina model terms, returns a DescriptiveValue
  sig do
    params(work_form_contributor: Contributor)
      .returns({ name: [{ value: T.untyped }], type: String, role: [{ value: T.untyped }] })
  end
  def contributor(work_form_contributor)
    # TODO: we may know status primary
    if work_form_contributor.person?
      {
        "name": [
          {
            "value": "#{work_form_contributor.last_name}, #{work_form_contributor.first_name}"
          }
        ],
        "type": 'person',
        # TODO: we will know code, uri, source code and source uri
        "role": [
          {
            "value": work_form_contributor.role
          }
        ]
      }
    else
      {
        "name": [
          {
            "value": work_form_contributor.full_name
          }
        ],
        "type": 'organization',
        "role": [
          {
            "value": work_form_contributor.role
          }
        ]
      }
    end
  end

  sig { returns(T::Array[RelatedLink::COCINA_HASH_TYPE]) }
  def related_links
    work.related_links.map(&:to_cocina_hash)
  end

  sig { returns(T::Array[RelatedWork::COCINA_HASH_TYPE]) }
  def related_works
    work.related_works.map(&:to_cocina_hash)
  end
end
# rubocop:enable Metrics/ClassLength
