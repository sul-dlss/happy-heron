# typed: strict
# frozen_string_literal: true

# This generates a RequestDRO Description for a work
# rubocop:disable Metrics/ClassLength
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
      contributor: contributors,
      subject: keywords,
      note: [abstract, citation, contact],
      event: [created_date, published_date].compact,
      relatedResource: related_resource
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

  sig do
    returns(T::Array[
      T.any(
        { type: String, access: { url: T::Array[{ value: String }] } },
        { type: String, access: { url: T::Array[{ value: String }] }, title: T::Array[{ value: String }] }
      )
    ])
  end
  def related_resource
    work.related_links.map do |rel_link|
      {
        type: 'related to',
        access: { url: [{ value: rel_link.url }] }
      }.tap do |h|
        h[:title] = [{ value: rel_link.link_title }] if rel_link.link_title.present?
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
