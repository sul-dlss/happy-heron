# typed: strong

# A manually created (partial) interface for Cocina::Models.
# Structs are hard for sorbet to infer automatically, see https://sorbet.org/docs/tstruct
module Cocina::Models
  class Title
    sig { params(value: String).void }
    def initialize(value:); end
  end

  class Contributor
    sig { params(name: T::Array[T.any(DescriptiveValue, T::Hash[T.untyped, T.untyped])],
                 type: String,
                 role: T::Array[T.any(DescriptiveValue, T::Hash[T.untyped, T.untyped])]).void }
    def initialize(name:, type:, role:); end
  end

  class DescriptiveValue
    sig do
      params(value: T.nilable(String),
             code: T.nilable(String),
             uri: T.nilable(String),
             type: T.nilable(String),
             source: T.nilable(Object),
             displayLabel: String,
             structuredValue: T::Array[DescriptiveValue]).void
    end
    def initialize(value: nil, code: nil, uri: nil, type: nil, source: nil, displayLabel: nil, structuredValue: nil); end
  end

  class Event
    sig do
      params(type: String,
             date: T.nilable(T::Array[T.any(DescriptiveValue, T::Hash[T.untyped, T.untyped])]),
             contributor: T.nilable(T::Array[T.any(Contributor, T::Hash[T.untyped, T.untyped])])).void
    end
    def initialize(type:, date: nil, contributor: nil); end
  end

  class DescriptiveAccessMetadata
  sig { params(url: T::Array[DescriptiveValue]).void }
  def initialize(url:); end
  end

  class RelatedResource
    sig do
      params(type: String,
             access: DescriptiveAccessMetadata,
             title: T::Array[DescriptiveValue],
             note: T::Array[DescriptiveValue]).void
    end
    def initialize(type:, access: nil, title: nil, note: nil); end
  end

  class DROStructural
    sig { params(contains: T::Array[T::Hash[T.untyped, T.untyped]], isMemberOf: T::Array[String]).void }
    def initialize(contains:, isMemberOf:); end
  end

  class RequestDROStructural
    sig { params(contains: T::Array[T::Hash[T.untyped, T.untyped]], isMemberOf: T::Array[String]).void }
    def initialize(contains:, isMemberOf:); end
  end

  class File
    sig do
      params(
        access: T::Hash[T.untyped, T.untyped],
        administrative: T::Hash[T.untyped, T.untyped],
        filename: String,
        hasMessageDigests: T::Array[T::Hash[T.untyped, T.untyped]],
        hasMimeType: String,
        label: String,
        size: String,
        type: String,
        version: Integer
      ).void
    end
    def initialize(access:, administrative:, filename:, hasMessageDigests:, hasMimeType:, label:, size:, type:, version:); end
  end

  class RequestFile
    sig do
      params(
        access: T::Hash[T.untyped, T.untyped],
        administrative: T::Hash[T.untyped, T.untyped],
        filename: String,
        hasMessageDigests: T::Array[T::Hash[T.untyped, T.untyped]],
        hasMimeType: String,
        label: String,
        size: String,
        type: String,
        version: Integer
      ).void
    end
    def initialize(access:, administrative:, filename:, hasMessageDigests:, hasMimeType:, label:, size:, type:, version:); end
  end
end
