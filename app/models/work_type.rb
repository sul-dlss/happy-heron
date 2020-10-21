# typed: strict
# frozen_string_literal: true

# Represents the list of valid work types
class WorkType
  extend T::Sig

  sig { returns(String) }
  attr_reader :id

  sig { returns(String) }
  attr_reader :label

  sig { params(id: String, label: String).void }
  def initialize(id:, label:)
    @id = id
    @label = label
  end

  # id is a value acceptable for MODS typeOfResource
  sig { returns(T::Array[WorkType]) }
  def self.all
    [
      new(id: 'data', label: 'Data'),
      new(id: 'image', label: 'Image'),
      new(id: 'mixed material', label: 'Mixed Materials'),
      new(id: 'other', label: 'Other'),
      new(id: 'software, multimedia', label: 'Software or Code'),
      new(id: 'sound', label: 'Sound'),
      new(id: 'text', label: 'Text'),
      new(id: 'video', label: 'Video')
    ]
  end
end
