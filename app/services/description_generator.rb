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

  # rubocop:disable Metrics/AbcSize
  sig { returns(Cocina::Models::Description) }
  def generate
    Cocina::Models::Description.new({
      title: title,
      contributor: ContributorsGenerator.generate(work_version: work_version).presence,
      subject: keywords.presence,
      note: [abstract, citation].compact.presence,
      event: generate_events.presence,
      relatedResource: related_resources.presence,
      form: TypesGenerator.generate(work_version: work_version).presence,
      access: contacts
    }.compact)
  end
  # rubocop:enable Metrics/AbcSize

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

  sig { returns(T::Array[Cocina::Models::RelatedResource]) }
  def related_resources
    RelatedLinksGenerator.generate(object: work_version) + related_works
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

  sig { returns(T.nilable(Cocina::Models::DescriptiveAccessMetadata)) }
  def contacts
    return if work_version.contact_emails.empty?

    access_contacts = work_version.contact_emails.map do |email|
      {
        value: email.email,
        type: 'email',
        displayLabel: 'Contact'
      }
    end

    Cocina::Models::DescriptiveAccessMetadata.new(
      accessContact: access_contacts
    )
  end

  sig { returns(T::Array[Cocina::Models::RelatedResource]) }
  def related_works
    work_version.related_works.map do |rel_work|
      Cocina::Models::RelatedResource.new(
        note: [
          Cocina::Models::DescriptiveValue.new(type: 'preferred citation', value: rel_work.citation)
        ]
      )
    end
  end
end
