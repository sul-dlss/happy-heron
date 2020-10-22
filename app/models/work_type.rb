# typed: strict
# frozen_string_literal: true

# Represents the list of valid work types
class WorkType
  extend T::Sig

  sig { returns(String) }
  attr_reader :id

  sig { returns(String) }
  attr_reader :label

  sig { returns(String) }
  attr_reader :icon

  sig { params(id: String, label: String, icon: String).void }
  def initialize(id:, label:, icon:)
    @id = id
    @label = label
    @icon = icon
  end

  # id is a value acceptable for MODS typeOfResource
  sig { returns(T::Array[WorkType]) }
  def self.all
    [
      new(id: 'data', label: 'Data', icon: 'chart-bar'),
      new(id: 'image', label: 'Image', icon: 'images'),
      new(id: 'mixed material', label: 'Multimedia', icon: 'play'),
      new(id: 'other', label: 'Other', icon: 'archive'),
      new(id: 'software, multimedia', label: 'Software or Code', icon: 'mouse'),
      new(id: 'sound', label: 'Sound', icon: 'microphone-alt'),
      new(id: 'text', label: 'Text', icon: 'book-open'),
      new(id: 'video', label: 'Video', icon: 'film')
    ]
  end
end
