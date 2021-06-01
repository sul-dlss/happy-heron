# typed: strict
# frozen_string_literal: true

# This generates a Collection Description
class CollectionDescriptionGenerator
  extend T::Sig

  sig { params(collection_version: CollectionVersion).returns(Cocina::Models::Description) }
  def self.generate(collection_version:)
    new(collection_version: collection_version).generate
  end

  sig { params(collection_version: CollectionVersion).void }
  def initialize(collection_version:)
    @collection_version = collection_version
  end

  sig { returns(Cocina::Models::Description) }
  def generate
    Cocina::Models::Description.new({
      title: title,
      relatedResource: related_resources.presence,
      access: access,
      purl: collection_version.collection.purl
    }.compact)
  end

  private

  sig { returns(CollectionVersion) }
  attr_reader :collection_version

  sig { returns(T::Array[Cocina::Models::Title]) }
  def title
    [
      Cocina::Models::Title.new(value: collection_version.name)
    ]
  end

  sig { returns(T::Array[Cocina::Models::RelatedResource]) }
  def related_resources
    RelatedLinksGenerator.generate(object: collection_version)
  end

  sig { returns(T.nilable(Cocina::Models::DescriptiveAccessMetadata)) }
  def access
    args = {
      accessContact: access_contacts,
      digitalRepository: repository
    }.compact
    return if args.empty?

    Cocina::Models::DescriptiveAccessMetadata.new(args)
  end

  sig { returns(T.nilable(T::Array[T::Hash[Symbol, String]])) }
  def repository
    return unless collection_version.collection.purl

    [{ value: 'Stanford Digital Repository' }]
  end

  sig { returns(T.nilable(T::Array[T::Hash[Symbol, String]])) }
  def access_contacts
    return if collection_version.contact_emails.empty?

    collection_version.contact_emails.map do |email|
      {
        value: email.email,
        type: 'email',
        displayLabel: 'Contact'
      }
    end
  end
end
