# frozen_string_literal: true

# Represents the list of valid work types
class WorkType
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

  MIXED_TYPES = %w[Data Image Portfolio Music Software/Code Sound Text Video].freeze

  SOUND_TYPES = ['Interview', 'Oral history', 'Podcast', 'Speech'].freeze

  TEXT_TYPES = [
    'Article', 'Capstone', 'Government document', 'Policy brief', 'Preprint', 'Report',
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
    '3D model', 'Animation', 'Article', 'Book', 'Book chapter', 'Broadcast', 'CAD', 'Capstone',
    'Code', 'Conference session', 'Correspondence', 'Course/instructional materials',
    'Data', 'Database', 'Documentary', 'Documentation', 'Dramatic performance',
    'Essay', 'Ethnography', 'Event', 'Experimental audio/video', 'Field recording',
    'Game', 'Geospatial data', 'Government document', 'Image', 'Interview',
    'Journal/periodical issue', 'Manuscript', 'Map', 'MIDI', 'Musical transcription',
    'Narrative film', 'Notated music', 'Oral history', 'Other spoken word',
    'Performance', 'Photograph', 'Piano roll', 'Podcast', 'Poetry reading',
    'Policy brief', 'Poster', 'Portfolio', 'Preprint', 'Presentation recording',
    'Presentation slides', 'Questionnaire', 'Remote sensing imagery', 'Report',
    'Software', 'Sound recording', 'Speaker notes', 'Speech', 'Story', 'Syllabus',
    'Tabular data', 'Technical report', 'Text', 'Text corpus', 'Thesis',
    'Transcript', 'Unedited recording', 'Video recording', 'Video art',
    'White paper', 'Working paper'
  ].freeze

  attr_reader :id, :label, :html_label, :icon, :cocina_type, :subtypes

  def initialize(**params)
    @id = params.fetch(:id)
    @label = params.fetch(:label)
    @html_label = params.fetch(:html_label)
    @icon = params.fetch(:icon)
    @subtypes = params.fetch(:subtypes)
    @cocina_type = params.fetch(:cocina_type)
  end

  def self.purl_reservation_type
    new(id: 'purl_reservation', label: 'PURL reservation', html_label: 'PURL reservation', icon: '', subtypes: [],
        cocina_type: Cocina::Models::ObjectType.object)
  end

  def self.find(id)
    (all + [purl_reservation_type]).find { |work| work.id == id } || raise(InvalidType, "Unknown worktype #{id}")
  end

  # rubocop:disable Metrics/AbcSize
  # id is a value acceptable for MODS typeOfResource

  def self.all
    [
      new(id: 'text', label: 'Text', html_label: 'Text', icon: 'book-open',
          subtypes: TEXT_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(id: 'data', label: 'Data', html_label: 'Data', icon: 'chart-bar',
          subtypes: DATA_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(id: 'software, multimedia', label: 'Software/Code', html_label: 'Software/<wbr>Code'.html_safe, icon: 'mouse',
          subtypes: SOFTWARE_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(id: 'image', label: 'Image', html_label: 'Image', icon: 'images',
          subtypes: IMAGE_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(id: 'sound', label: 'Sound', html_label: 'Sound', icon: 'microphone-alt',
          subtypes: SOUND_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(id: 'video', label: 'Video', html_label: 'Video', icon: 'film',
          subtypes: VIDEO_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(id: 'music', label: 'Music', html_label: 'Music', icon: 'music',
          subtypes: MUSIC_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(id: 'mixed material', label: 'Mixed Materials', html_label: 'Mixed Materials', icon: 'play',
          subtypes: MIXED_TYPES, cocina_type: Cocina::Models::ObjectType.object),
      new(id: 'other', label: 'Other', html_label: 'Other', icon: 'archive',
          subtypes: [], cocina_type: Cocina::Models::ObjectType.object)
    ]
  end
  # rubocop:enable Metrics/AbcSize

  def self.type_list
    all.map(&:id).sort
  end

  def self.more_types
    MORE_TYPES
  end

  def self.subtypes_for(id, include_more_types: false)
    subtypes = find(id).subtypes
    return subtypes unless include_more_types

    subtypes + more_types
  end

  def self.to_h
    all.to_h { |type| [type.id, type.subtypes] }
  end

  def self.to_json
    to_h.to_json
  end
end
