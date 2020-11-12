# typed: false
# frozen_string_literal: true

require 'reform/form/coercion'

# The form for deposit work creation and editing (which includes validation)
class WorkForm < DraftWorkForm
  validates :abstract, :access, :title, presence: true
  validates 'created(1i)', 'created_range(1i)', 'created_range(4i)',
            inclusion: { in: Settings.earliest_created_year..Time.zone.today.year },
            allow_nil: true
  validates 'published(1i)',
            inclusion: { in: Settings.earliest_publication_year..Time.zone.today.year },
            allow_nil: true
  validates 'release', presence: true, inclusion: { in: %w[immediate embargo] }
  validates :keywords, length: { minimum: 1, message: 'Please add at least one keyword.' }
  validates :attached_files, length: { minimum: 1, message: 'Please add at least one file.' }
  validates :contact_email, presence: true, format: { with: Devise.email_regexp }
  validates :license, presence: true, inclusion: { in: License.license_list }
  validates :subtype, work_subtype: true
  validates :work_type, presence: true, work_type: true
end
