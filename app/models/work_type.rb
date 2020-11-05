# typed: true
# frozen_string_literal: true

# Represents the list of valid work types
# rubocop:disable Metrics/ClassLength
class WorkType
  extend T::Sig

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

  sig { returns(T::Array[String]) }
  attr_reader :subtypes

  sig { params(id: String, label: String, icon: String, subtypes: T::Array[String]).void }
  def initialize(id:, label:, icon:, subtypes:)
    @id = id
    @label = label
    @icon = icon
    @subtypes = subtypes
  end

  sig { params(id: T.nilable(String)).returns(T.nilable(WorkType)) }
  def self.find(id)
    all.find { |work| work.id == id }
  end

  # id is a value acceptable for MODS typeOfResource
  sig { returns(T::Array[WorkType]) }
  def self.all
    [
      new(id: 'data', label: 'Data', icon: 'chart-bar', subtypes: DATA_TYPES),
      new(id: 'image', label: 'Image', icon: 'images', subtypes: IMAGE_TYPES),
      new(id: 'mixed materials', label: 'Mixed Materials', icon: 'play', subtypes: MIXED_TYPES),
      new(id: 'other', label: 'Other', icon: 'archive', subtypes: []),
      new(id: 'software, multimedia', label: 'Software or Code', icon: 'mouse', subtypes: SOFTWARE_TYPES),
      new(id: 'sound', label: 'Sound', icon: 'microphone-alt', subtypes: SOUND_TYPES),
      new(id: 'text', label: 'Text', icon: 'book-open', subtypes: TEXT_TYPES),
      new(id: 'video', label: 'Video', icon: 'film', subtypes: VIDEO_TYPES)
    ]
  end

  sig { returns(T::Array[String]) }
  def self.type_list
    all.map(&:id).sort
  end

  sig { params(id: T.nilable(String)).returns(T::Array[String]) }
  def self.subtypes_for(id)
    find(id)&.subtypes || []
  end
end
# rubocop:enable Metrics/ClassLength
