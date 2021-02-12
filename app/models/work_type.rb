# typed: true
# frozen_string_literal: true

# Represents the list of valid work types
class WorkType
  extend T::Sig

  class InvalidType < StandardError; end

  MINIMUM_REQUIRED_MUSIC_SUBTYPES = 1
  MINIMUM_REQUIRED_MIXED_MATERIAL_SUBTYPES = 2
  MIXED_MATERIAL = 'mixed material'
  MUSIC = 'music'
  OTHER = 'other'

  DATA_TYPES = [
    '3D model', 'Database', 'Documentation', 'Geospatial data', 'Image',
    'Tabular data', 'Text corpus'
  ].freeze

  VIDEO_TYPES = [
    'Conference session', 'Documentary', 'Event', 'Oral history', 'Performance'
  ].freeze

  MIXED_TYPES = %w[Data Image Software/Code Sound Text Video].freeze

  SOUND_TYPES = ['Interview', 'Oral history', 'Podcast', 'Speech'].freeze

  TEXT_TYPES = [
    'Article', 'Government document', 'Policy brief', 'Preprint', 'Report',
    'Technical report', 'Thesis', 'Working paper'
  ].freeze

  SOFTWARE_TYPES = %w[Code Documentation Game].freeze

  IMAGE_TYPES = ['CAD', 'Map', 'Photograph', 'Poster', 'Presentation slides'].freeze

  MUSIC_TYPES = [
    'Data',
    'Image',
    'MIDI',
    'Musical transcription',
    'Notated music',
    'Piano roll',
    'Software/Code',
    'Sound',
    'Text',
    'Video'
  ].freeze

  # These types appear below the fold and may be expanded
  MORE_TYPES = [
    '3D model', 'Animation', 'Article', 'Book', 'Book chapter', 'Broadcast', 'CAD',
    'Code', 'Conference session', 'Correspondence', 'Course/instructional materials',
    'Data', 'Database', 'Documentary', 'Documentation', 'Dramatic performance',
    'Essay', 'Ethnography', 'Event', 'Experimental audio/video', 'Field recording',
    'Game', 'Geospatial data', 'Government document', 'Image', 'Interview',
    'Journal/periodical issue', 'Manuscript', 'Map', 'MIDI', 'Musical transcription',
    'Narrative film', 'Notated music', 'Oral history', 'Other spoken word',
    'Performance', 'Photograph', 'Piano roll', 'Podcast', 'Poetry reading',
    'Policy brief', 'Poster', 'Preprint', 'Presentation recording',
    'Presentation slides', 'Questionnaire', 'Remote sensing imagery', 'Report',
    'Software', 'Sound recording', 'Speaker notes', 'Speech', 'Story', 'Syllabus',
    'Tabular data', 'Technical report', 'Text', 'Text corpus', 'Thesis',
    'Transcript', 'Unedited recording', 'Video recording', 'Video art',
    'White paper', 'Working paper'
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

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # id is a value acceptable for MODS typeOfResource
  sig { returns(T::Array[WorkType]) }
  def self.all
    [
      new(id: 'text', label: 'Text', icon: 'book-open', subtypes: TEXT_TYPES,
          cocina_type: Cocina::Models::Vocab.object),
      new(id: 'data', label: 'Data', icon: 'chart-bar', subtypes: DATA_TYPES,
          cocina_type: Cocina::Models::Vocab.object),
      new(id: 'software, multimedia', label: 'Software/Code', icon: 'mouse', subtypes: SOFTWARE_TYPES,
          cocina_type: Cocina::Models::Vocab.object),
      new(id: 'image', label: 'Image', icon: 'images', subtypes: IMAGE_TYPES,
          cocina_type: Cocina::Models::Vocab.image),
      new(id: 'sound', label: 'Sound', icon: 'microphone-alt', subtypes: SOUND_TYPES,
          cocina_type: Cocina::Models::Vocab.media),
      new(id: 'video', label: 'Video', icon: 'film', subtypes: VIDEO_TYPES,
          cocina_type: Cocina::Models::Vocab.media),
      new(id: 'music', label: 'Music', icon: 'music', subtypes: MUSIC_TYPES,
          cocina_type: Cocina::Models::Vocab.object),
      new(id: 'mixed material', label: 'Mixed Materials', icon: 'play', subtypes: MIXED_TYPES,
          cocina_type: Cocina::Models::Vocab.object),
      new(id: 'other', label: 'Other', icon: 'archive', subtypes: [],
          cocina_type: Cocina::Models::Vocab.object)
    ]
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  sig { returns(T::Array[String]) }
  def self.type_list
    all.map(&:id).sort
  end

  sig { returns(T::Array[String]) }
  def self.more_types
    MORE_TYPES
  end

  sig { params(id: T.nilable(String), include_more_types: T::Boolean).returns(T::Array[String]) }
  def self.subtypes_for(id, include_more_types: false)
    subtypes = find(id).subtypes
    return subtypes unless include_more_types

    subtypes + more_types
  end

  sig { returns(T::Hash[String, T::Array[String]]) }
  def self.to_h
    all.map { |type| [type.id, type.subtypes] }.to_h
  end

  sig { returns(String) }
  def self.to_json
    to_h.to_json
  end
end
