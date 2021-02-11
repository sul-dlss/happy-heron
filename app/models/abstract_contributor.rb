# typed: true
# frozen_string_literal: true

# This is the parent of Author and Contributors
# It is necessary so that Rails STI will assign the proper type to each concrete model
# and so that when you query Work#contributors you only get the non-author contributors.
class AbstractContributor < ApplicationRecord
  extend T::Sig
  SEPARATOR = '|'

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
        'Distributor',
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

  belongs_to :work_version

  validates :first_name, presence: true, if: :person?
  validates :last_name, presence: true, if: :person?
  validates :full_name, presence: true, unless: :person?

  validates :contributor_type, presence: true, inclusion: { in: %w[person organization] }
  validates :role, presence: true, inclusion: { in: GROUPED_ROLES.values.flatten }

  sig { returns(T::Boolean) }
  def person?
    contributor_type == 'person'
  end

  # used by DraftWorkForm
  sig { returns(String) }
  def role_term
    [contributor_type, role].join(SEPARATOR)
  end

  # used by DraftWorkForm for setting values from the form.
  sig { params(val: String).void }
  def role_term=(val)
    contributor_type, role = val.split(SEPARATOR)
    self.attributes = { contributor_type: contributor_type, role: role }
  end
end
