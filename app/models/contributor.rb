# typed: true
# frozen_string_literal: true

# Models a contributor to a Work
class Contributor < ApplicationRecord
  extend T::Sig

  belongs_to :work

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :contributor_type, presence: true, inclusion: { in: %w[person organization conference] }
  validates :role, presence: true,
                   inclusion: {
                     in: [
                       'Advisor',
                       'Author',
                       'Collector',
                       'Contributing author',
                       'Creator',
                       'Editor',
                       'Primary advisor',
                       'Principal investigator',
                       'Degree granting institution',
                       'Distributor',
                       'Publisher',
                       'Sponsor',
                       'Conference'
                     ]
                   }

  # This is used by the form
  sig { returns(String) }
  def role_term
    [contributor_type, role].join(SEPARATOR)
  end

  # This is used by the the controller for setting values from the form.
  sig { params(val: String).void }
  def role_term=(val)
    contributor_type, role = val.split(SEPARATOR)
    self.attributes = { contributor_type: contributor_type, role: role }
  end

  # The list for the form
  sig { returns(T::Array[T::Array[T.any(String, T::Array[String])]]) }
  def self.grouped_options
    ROLE_LABEL.map do |key, label|
      [label, GROUPED_ROLES.fetch(key).map { |role| [role, [key, role].join(SEPARATOR)] }]
    end
  end

  SEPARATOR = '|'

  ROLE_LABEL = {
    'person' => 'Individual',
    'organization' => 'Organization',
    'conference' => 'Conference'
  }.freeze

  GROUPED_ROLES = {
    'person' =>
      [
        'Advisor',
        'Author',
        'Collector',
        'Contributing author',
        'Creator',
        'Editor',
        'Primary advisor',
        'Principal investigator'
      ],
    'organization' =>
      [
        'Author',
        'Contributing author',
        'Degree granting institution',
        'Distributor',
        'Publisher',
        'Sponsor'
      ],
    'conference' =>
      %w[Conference]
  }.freeze
end
