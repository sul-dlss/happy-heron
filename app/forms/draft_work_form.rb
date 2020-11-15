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
  property :contact_email
  property :abstract
  property :citation
  property :collection_id
  property :access
  property :license
  property :agree_to_terms
  property :created_edtf, edtf: true, range: true
  property :published_edtf, edtf: true

  property :release, virtual: true, default: 'immediate'
  property :embargo_date, embargo_date: true, assign_if: ->(params) { params['release'] == 'embargo' }

  validates :created_edtf, created_in_past: true
  validates :published_edtf, created_in_past: true

  collection :contributors,
             populator: ContributorPopulator.new(:contributors, Contributor),
             prepopulator: ->(*) { contributors << Contributor.new } do
    property :id
    property :first_name
    property :last_name
    property :full_name
    property :role_term
    property :_destroy, virtual: true
  end

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

  collection :keywords, populator: KeywordsPopulator.new(:keywords, Keyword) do
    property :id
    property :label
    property :uri
    property :_destroy, virtual: true
  end

  collection :related_works,
             populator: RelatedWorksPopulator.new(:related_works, RelatedWork),
             prepopulator: ->(*) { related_works << RelatedWork.new } do
    property :id
    property :citation
    property :_destroy, virtual: true
  end

  collection :related_links, populator: RelatedLinksPopulator.new(:related_links, RelatedLink),
                             prepopulator: ->(*) { related_links << RelatedLink.new } do
    property :id
    property :link_title
    property :url
    property :_destroy, virtual: true
  end
end
