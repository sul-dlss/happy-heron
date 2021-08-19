# frozen_string_literal: true

# The form for reserving a PURL
class ReservationForm < Reform::Form
  include Composition

  property :work_type, on: :work_version, default: WorkType.purl_reservation_type.id
  property :abstract, on: :work_version, default: ''
  property :license, on: :work_version, default: 'none'
  property :title, on: :work_version
  property :assign_doi, on: :work

  validates :title, presence: true

  def deserialize!(params)
    params['license'] = collection.default_license if collection.default_license
    deserialize_doi(params)
    super
  end

  # Force assign_doi to match what the collection enforces
  def deserialize_doi(params)
    case model[:work].collection.doi_option
    when 'no'
      params['assign_doi'] = 'false'
    when 'yes'
      params['assign_doi'] = 'true'
    end
  end

  def collection
    model.fetch(:work).collection
  end

  def work_version
    model.fetch(:work_version)
  end

  def work
    model.fetch(:work)
  end

  # Ensure that this work version is now the head of the work versions for this work
  def save_model
    Work.transaction do
      super
      work.update(head: work_version)
    end
  end
end
