# typed: strict
# frozen_string_literal: true

# This generates a RequestDRO Description for a work
class DescriptionGenerator
  extend T::Sig

  sig { params(work_version: WorkVersion).returns(Cocina::Models::Description) }
  def self.generate(work_version:)
    new(work_version: work_version).generate
  end

  sig { params(work_version: WorkVersion).void }
  def initialize(work_version:)
    @work_version = work_version
  end

  sig { returns(Cocina::Models::Description) }
  def generate
    Cocina::Models::Description.new({
                                      title: title,
                                      contributor: ContributorsGenerator.generate(work_version: work_version),
                                      subject: keywords,
                                      note: [abstract, citation] + contacts,
                                      event: generate_events,
                                      relatedResource: related_links + related_works,
                                      form: generate_form
                                    }, false, false)
  end

  private

  sig { returns(WorkVersion) }
  attr_reader :work_version

  sig { returns(T::Array[Cocina::Models::Title]) }
  def title
    [
      Cocina::Models::Title.new(value: work_version.title)
    ]
  end

  sig { returns(T::Array[Cocina::Models::Event]) }
  def generate_events
    pub_events = ContributorsGenerator.events_from_publisher_contributors(work_version: work_version,
                                                                          pub_date: published_date)
    return [T.must(created_date)] + pub_events if pub_events.present? && created_date
    return pub_events if pub_events.present? # and no created_date

    [created_date, published_date].compact # no pub_events
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def generate_form
    TypesGenerator.generate(work_version: work_version) +
      ContributorsGenerator.form_array_from_contributor_event(work_version: work_version)
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def keywords
    work_version.keywords.map do |keyword|
      Cocina::Models::DescriptiveValue.new(value: T.must(keyword.label), type: 'topic')
    end
  end

  sig { returns(Cocina::Models::DescriptiveValue) }
  def abstract
    Cocina::Models::DescriptiveValue.new(
      value: work_version.abstract,
      type: 'summary'
    )
  end

  sig { returns(T.nilable(Cocina::Models::DescriptiveValue)) }
  def citation
    return unless work_version.citation

    # :link: is a special placeholder in dor-services-app.
    # See https://github.com/sul-dlss/dor-services-app/pull/1566/files#diff-30396654f0ad00ad1daa7292fd8327759d7ff7f3b92f98f40a2e25b6839807e2R13
    exportable_citation = T.must(work_version.citation).gsub(WorkVersion::LINK_TEXT, ':link:')

    Cocina::Models::DescriptiveValue.new(
      value: exportable_citation,
      type: 'preferred citation'
    )
  end

  sig { returns(T.nilable(Cocina::Models::Event)) }
  def created_date
    date = work_version.created_edtf
    return unless date

    Cocina::Models::Event.new(
      type: 'creation',
      date: [
        {
          value: date.respond_to?(:edtf) ? date.edtf : date.to_s,
          encoding: { code: 'edtf' }
        }
      ]
    )
  end

  sig { returns(T.nilable(Cocina::Models::Event)) }
  def published_date
    date = work_version.published_edtf
    return unless date

    Cocina::Models::Event.new(
      type: 'publication',
      date: [
        {
          value: date.respond_to?(:edtf) ? date.edtf : date.to_s,
          encoding: { code: 'edtf' },
          status: 'primary'
        }
      ]
    )
  end

  sig { returns(T::Array[Cocina::Models::DescriptiveValue]) }
  def contacts
    work_version.contact_emails.map do |email|
      Cocina::Models::DescriptiveValue.new(
        value: email.email,
        type: 'contact',
        displayLabel: 'Contact'
      )
    end
  end

  sig { returns(T::Array[Cocina::Models::RelatedResource]) }
  def related_links
    work_version.related_links.map do |rel_link|
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
    work_version.related_works.map do |rel_work|
      Cocina::Models::RelatedResource.new(
        type: 'related to',
        note: [
          Cocina::Models::DescriptiveValue.new(type: 'preferred citation', value: rel_work.citation)
        ]
      )
    end
  end
end
