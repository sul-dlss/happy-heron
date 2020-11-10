# typed: true
# frozen_string_literal: true

# Models a contributor to a Work
class Contributor < ApplicationRecord
  extend T::Sig

  SEPARATOR = '|'

  ROLE_LABEL = {
    'person' => 'Individual',
    'organization' => 'Organization'
  }.freeze

  GROUPED_ROLES = {
    'person' =>
      [
        'Author',
        'Composer',
        'Contributing author',
        'Copyright holder',
        'Creator',
        'Data collector',
        'Data contributor',
        'Editor',
        'Event organizer',
        'Interviewee',
        'Interviewer',
        'Performer',
        'Photographer',
        'Primary thesis advisor',
        'Principal investigator',
        'Researcher',
        'Software developer',
        'Speaker',
        'Thesis advisor'
      ],
    'organization' =>
      [
        'Author',
        'Conference',
        'Contributing author',
        'Copyright holder',
        'Data collector',
        'Data contributor',
        'Degree granting institution',
        'Event',
        'Event organizer',
        'Funder',
        'Host institution',
        'Issuing body',
        'Publisher',
        'Research group',
        'Sponsor'
      ]
  }.freeze

  belongs_to :work

  validates :first_name, presence: true, if: :person?
  validates :last_name, presence: true, if: :person?
  validates :full_name, presence: true, unless: :person?

  validates :contributor_type, presence: true, inclusion: { in: %w[person organization] }
  validates :role, presence: true, inclusion: { in: GROUPED_ROLES.values.flatten }

  sig { returns(T::Boolean) }
  def person?
    contributor_type == 'person'
  end

  # used by work_form
  sig { returns(String) }
  def role_term
    [contributor_type, role].join(SEPARATOR)
  end

  # used by work_controller for setting values from the form.
  sig { params(val: String).void }
  def role_term=(val)
    contributor_type, role = val.split(SEPARATOR)
    self.attributes = { contributor_type: contributor_type, role: role }
  end

  # list for work_form pulldown
  sig { returns(T::Array[T::Array[T.any(String, T::Array[String])]]) }
  def self.grouped_options
    ROLE_LABEL.map do |key, label|
      [label, GROUPED_ROLES.fetch(key).map { |role| [role, [key, role].join(SEPARATOR)] }]
    end
  end
end
