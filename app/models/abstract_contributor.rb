# frozen_string_literal: true

# This is the parent of Author and Contributors
# It is necessary so that Rails STI will assign the proper type to each concrete model
# and so that when you query Work#contributors you only get the non-author contributors.
class AbstractContributor < ApplicationRecord
  SEPARATOR = "|"

  # NOTE: "Author" is deliberately set to first (out of alpha order), as it should be the default
  PERSON_ROLES = [
    "Author",
    "Advisor",
    "Composer",
    "Contributing author",
    "Copyright holder",
    "Creator",
    "Data collector",
    "Data contributor",
    "Editor",
    "Event organizer",
    "Interviewee",
    "Interviewer",
    "Performer",
    "Photographer",
    "Primary thesis advisor",
    "Principal investigator",
    "Researcher",
    "Software developer",
    "Speaker",
    "Thesis advisor"
  ].freeze

  ORGANIZATION_ROLES = [
    "Author",
    "Conference",
    "Contributing author",
    "Copyright holder",
    "Data collector",
    "Data contributor",
    "Degree granting institution",
    "Distributor",
    "Event",
    "Event organizer",
    "Funder",
    "Host institution",
    "Issuing body",
    "Publisher",
    "Research group",
    "Sponsor"
  ].freeze

  GROUPED_ROLES = {
    "person" => PERSON_ROLES,
    "organization" => ORGANIZATION_ROLES
  }.freeze

  belongs_to :work_version
  has_many :affiliations, dependent: :destroy

  validates :contributor_type, presence: true, inclusion: {in: %w[person organization]}

  validates :orcid, format: {with: Orcid::REGEX}, allow_nil: true, if: :person?
  validates :orcid, absence: true, unless: :person?

  strip_attributes allow_empty: true, only: [:first_name, :last_name, :full_name]

  def self.grouped_roles(citable:)
    return GROUPED_ROLES if citable

    {
      "person" => PERSON_ROLES,
      "organization" => (ORGANIZATION_ROLES + ["Department"]).sort
    }
  end

  validates :role, presence: true, inclusion: {in: grouped_roles(citable: false).values.flatten}

  def person?
    contributor_type == "person"
  end

  # used by DraftWorkForm

  def role_term
    [contributor_type, role].join(SEPARATOR)
  end

  # used by DraftWorkForm for setting values from the form.

  def role_term=(val)
    contributor_type, role = val.split(SEPARATOR)
    self.attributes = {contributor_type:, role:}
  end
end
