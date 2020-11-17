# typed: true
# frozen_string_literal: true

# Represents the list of valid work types
class WorkType
  extend T::Sig

  class InvalidType < StandardError; end

  DATA_TYPES = [
    '3D model',
    'Audio',
    'Database ',
    'GIS',
    'Image ',
    'Questionnaire',
    'Remote sensing imagery',
    'Software/code',
    'Statistical model',
    'Tabular data',
    'Text corpus',
    'Text documentation',
    'Video'
  ].freeze

  VIDEO_TYPES = [
    'Animation',
    'Broadcast',
    'Conference session',
    'Course/instruction',
    'Documentary',
    'Ethnography',
    'Event',
    'Experimental',
    'Field recordings',
    'Narrative film',
    'Oral history',
    'Performance',
    'Presentation',
    'Unedited footage',
    'Video art'
  ].freeze

  MIXED_TYPES = [
    'Data',
    'Image',
    'Software/Code',
    'Sound',
    'Text',
    'Video'
  ].freeze

  SOUND_TYPES = [
    'Course/instruction',
    'Documentary',
    'Dramatic performance',
    'Ethnography',
    'Field recordings',
    'Interview',
    'MIDI',
    'Musical notation',
    'Musical performance ',
    'Oral history',
    'Other spoken word',
    'Podcast',
    'Poetry reading',
    'Speech',
    'Story',
    'Transcript',
    'Unedited recording'
  ].freeze

  TEXT_TYPES = [
    'Article',
    'Book',
    'Book chapter',
    'Correspondence',
    'Essay',
    'Government document',
    'Journal/periodical',
    'Manuscript',
    'Poster',
    'Presentation slides',
    'Report',
    'Speech',
    'Syllabus',
    'Teaching materials',
    'Technical report',
    'Thesis',
    'Transcription',
    'White paper',
    'Working paper'
  ].freeze

  SOFTWARE_TYPES = %w[
    Code
    Documentation
    Game
  ].freeze

  IMAGE_TYPES = [
    'CAD',
    'Map',
    'Photograph',
    'Poster',
    'Presentation slides'
  ].freeze

  sig { returns(String) }
  attr_reader :id

  sig { returns(String) }
  attr_reader :label

  sig { returns(String) }
  attr_reader :icon

  sig { returns(String) }
  attr_reader :cocina_type

  sig { returns(T::Array[String]) }
  attr_reader :subtypes

  sig { params(id: String, label: String, icon: String, subtypes: T::Array[String], cocina_type: String).void }
  def initialize(id:, label:, icon:, subtypes:, cocina_type:)
    @id = id
    @label = label
    @icon = icon
    @subtypes = subtypes
    @cocina_type = cocina_type
  end

  sig { params(id: T.nilable(String)).returns(WorkType) }
  def self.find(id)
    all.find { |work| work.id == id } || raise(InvalidType, "Unknown worktype #{id}")
  end

  # id is a value acceptable for MODS typeOfResource
  sig { returns(T::Array[WorkType]) }
  def self.all
    [
      new(id: 'text', label: 'Text', icon: 'book-open', subtypes: TEXT_TYPES,
          cocina_type: Cocina::Models::Vocab.document),
      new(id: 'data', label: 'Data', icon: 'chart-bar', subtypes: DATA_TYPES,
          cocina_type: Cocina::Models::Vocab.object),
      new(id: 'software, multimedia', label: 'Software or Code', icon: 'mouse', subtypes: SOFTWARE_TYPES,
          cocina_type: Cocina::Models::Vocab.object),
      new(id: 'image', label: 'Image', icon: 'images', subtypes: IMAGE_TYPES,
          cocina_type: Cocina::Models::Vocab.image),
      new(id: 'sound', label: 'Sound', icon: 'microphone-alt', subtypes: SOUND_TYPES,
          cocina_type: Cocina::Models::Vocab.media),
      new(id: 'video', label: 'Video', icon: 'film', subtypes: VIDEO_TYPES,
          cocina_type: Cocina::Models::Vocab.media),
      new(id: 'mixed material', label: 'Mixed Materials', icon: 'play', subtypes: MIXED_TYPES,
          cocina_type: Cocina::Models::Vocab.object),
      new(id: 'other', label: 'Other', icon: 'archive', subtypes: [],
          cocina_type: Cocina::Models::Vocab.object)
    ]
  end

  sig { returns(T::Array[String]) }
  def self.type_list
    all.map(&:id).sort
  end

  sig { params(id: T.nilable(String)).returns(T::Array[String]) }
  def self.subtypes_for(id)
    find(id).subtypes
  end
end
