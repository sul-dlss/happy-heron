# typed: strict
# frozen_string_literal: true

# This generates a RequestDRO Description for a work
class DescriptionGenerator
  extend T::Sig

  sig { params(work: Work).returns(Cocina::Models::Description) }
  def self.generate(work:)
    new(work: work).generate
  end

  sig { params(work: Work).void }
  def initialize(work:)
    @work = work
  end

  sig { returns(Cocina::Models::Description) }
  def generate
    Cocina::Models::Description.new({
                                      title: title,
                                      contributor: ContributorsGenerator.generate(work: work),
                                      subject: keywords,
                                      note: [abstract, citation, contact],
                                      event: generate_events,
                                      relatedResource: related_links + related_works,
                                      form: generate_form
                                    }, false, false)
  end

  private

  sig { returns(Work) }
  attr_reader :work

  sig { returns(T::Array[Cocina::Models::Title]) }
  def title
    [
      Cocina::Models::Title.new(value: work.title)
    ]
  end

  sig { returns(T::Array[Cocina::Models::Event]) }
  def generate_events
    pub_events = ContributorsGenerator.events_from_publisher_contributors(work: work, pub_date: published_date)
    return [T.must(created_date)] + pub_events if pub_events.present? && created_date
    return pub_events if pub_events.present? # and no created_date

    [created_date, published_date].compact # no pub_events
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def generate_form
    TypesGenerator.generate(work: work) + ContributorsGenerator.form_array_from_contributor_event(work: work)
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def keywords
    work.keywords.map do |keyword|
      Cocina::Models::DescriptiveValue.new(value: T.must(keyword.label), type: 'topic')
    end
  end

  sig { returns(Cocina::Models::DescriptiveValue) }
  def abstract
    Cocina::Models::DescriptiveValue.new(
      value: work.abstract,
      type: 'summary'
    )
  end

  sig { returns(T.nilable(Cocina::Models::DescriptiveValue)) }
  def citation
    return unless work.citation

    Cocina::Models::DescriptiveValue.new(
      value: T.must(work.citation),
      type: 'preferred citation'
    )
  end

  sig { returns(T.nilable(Cocina::Models::Event)) }
  def created_date
    return unless work.created_edtf

    Cocina::Models::Event.new(
      type: 'creation',
      date: [
        {
          value: work.created_edtf,
          encoding: { code: 'edtf' }
        }
      ]
    )
  end

  sig { returns(T.nilable(Cocina::Models::Event)) }
  def published_date
    return unless work.published_edtf

    Cocina::Models::Event.new(
      type: 'publication',
      date: [
        {
          value: work.published_edtf,
          encoding: { code: 'edtf' }
        }
      ]
    )
  end

  sig { returns(Cocina::Models::DescriptiveValue) }
  def contact
    Cocina::Models::DescriptiveValue.new(
      value: work.contact_email,
      type: 'contact',
      displayLabel: 'Contact'
    )
  end

  sig { returns(T::Array[Cocina::Models::RelatedResource]) }
  def related_links
    work.related_links.map do |rel_link|
      resource_attrs = {
        type: 'related to',
        access: Cocina::Models::DescriptiveAccessMetadata.new(
          url: [Cocina::Models::DescriptiveValue.new(value: rel_link.url)]
        )
      }
      resource_attrs[:title] = [{ value: rel_link.link_title }] if rel_link.link_title.present?
      Cocina::Models::RelatedResource.new(resource_attrs)
    end
  end

  sig { returns(T::Array[Cocina::Models::RelatedResource]) }
  def related_works
    work.related_works.map do |rel_work|
      Cocina::Models::RelatedResource.new(
        type: 'related to',
        note: [
          Cocina::Models::DescriptiveValue.new(type: 'preferred citation', value: rel_work.citation)
        ]
      )
    end
  end
end
