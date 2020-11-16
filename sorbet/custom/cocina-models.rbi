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
    sig { params(type: String, date: T::Array[T.any(DescriptiveValue, T::Hash[T.untyped, T.untyped])]).void }
    def initialize(type:, date:); end
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
end
