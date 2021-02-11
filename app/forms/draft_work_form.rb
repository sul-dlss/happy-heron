# typed: false
# frozen_string_literal: true

require 'reform/form/coercion'

# The form for draft work creation and editing
class DraftWorkForm < Reform::Form
  feature Edtf
  feature EmbargoDate

  property :work_type
  property :subtype
  property :title
  property :abstract
  property :citation
  property :default_citation, virtual: true, default: true
  property :citation_auto, virtual: true
  property :collection_id
  property :access
  property :license
  property :agree_to_terms
  property :created_type, virtual: true, prepopulator: (proc do |*|
    self.created_type = created_edtf.is_a?(EDTF::Interval) ? 'range' : 'single'
  end)
  property :created_edtf, edtf: true, range: true
  property :published_edtf, edtf: true
  property :release, virtual: true, prepopulator: (proc do |*|
    self.release = embargo_date.present? ? 'embargo' : 'immediate'
  end)
  property :embargo_date, embargo_date: true

  validates_with EmbargoDateParts,
                 if: proc { |form| form.user_can_set_availability? && form.release != 'immediate' }

  def user_can_set_availability?
    model.collection.user_can_set_availability?
  end

  def deserialize!(params)
    # Choose between using the user provided citation and the auto-generated citation
    params['citation'] = params.delete('citation_auto') if params['default_citation'] == 'true'
    deserialize_embargo(params)
    access_from_collection(params)
    deserialize_license(params)
    super(params)
  end

  # Ensure the collection default overwrites whatever the user supplied
  # rubocop:disable Metrics/AbcSize
  def deserialize_embargo(params)
    case model.collection.release_option
    when 'delay'
      release_date = model.collection.release_date
      params['embargo_date(1i)'] = release_date.year.to_s
      params['embargo_date(2i)'] = release_date.month.to_s
      params['embargo_date(3i)'] = release_date.day.to_s
    when 'immediate'
      params['embargo_date(1i)'] = nil
      params['embargo_date(2i)'] = nil
      params['embargo_date(3i)'] = nil
    end
  end
  # rubocop:enable Metrics/AbcSize

  def access_from_collection(params)
    return if model.collection.access == 'depositor-selects'

    params['access'] = model.collection.access
  end

  # Ensure the collection's required license overwrites whatever the user supplied
  def deserialize_license(params)
    return unless model.collection.required_license

    params['license'] = model.collection.required_license
  end

  contributor = lambda { |*|
    property :id
    property :first_name
    property :last_name
    property :full_name
    property :role_term
    property :_destroy, virtual: true
  }

  collection :contributors,
             populator: ContributorPopulator.new(:contributors, Contributor),
             prepopulator: ->(*) { contributors << Contributor.new if contributors.blank? },
             &contributor

  collection :authors,
             populator: ContributorPopulator.new(:authors, Author),
             prepopulator: ->(*) { authors << Author.new if authors.blank? },
             &contributor

  collection :attached_files, populator: AttachedFilesPopulator.new(:attached_files, AttachedFile) do
    property :id
    property :label
    property :hide
    # The file property is virtual so it doesn't get set on update, which causes:
    # ArgumentError: Could not find or build blob
    # So we set it manually when creating.
    property :file, virtual: true
    property :_destroy, virtual: true
  end

  collection :contact_emails, populator: ContactEmailsPopulator.new(:contact_emails, ContactEmail),
                              prepopulator: ->(*) { contact_emails << ContactEmail.new if contact_emails.blank? } do
    property :id
    property :email
    property :_destroy, virtual: true
  end

  collection :keywords, populator: KeywordsPopulator.new(:keywords, Keyword) do
    property :id
    property :label
    property :uri
    property :_destroy, virtual: true
  end

  collection :related_works,
             populator: RelatedWorksPopulator.new(:related_works, RelatedWork),
             prepopulator: ->(*) { related_works << RelatedWork.new if related_works.blank? } do
    property :id
    property :citation
    property :_destroy, virtual: true
  end

  collection :related_links, populator: RelatedLinksPopulator.new(:related_links, RelatedLink),
                             prepopulator: ->(*) { related_links << RelatedLink.new if related_links.blank? } do
    property :id
    property :link_title
    property :url
    property :_destroy, virtual: true
  end
end
