# frozen_string_literal: true

require "reform/form/coercion"

# The form for draft work creation and editing
class BaseWorkForm < Reform::Form
  feature Edtf
  feature EmbargoDate
  include Composition
  include ContributorForm
  feature Coercion # Casts properties to a specific type

  property :work_type, on: :work_version
  property :version_description, on: :work_version
  property :subtype, on: :work_version
  property :title, on: :work_version, type: Dry::Types["params.nil"] | Dry::Types["string"]
  property :abstract, on: :work_version, type: Dry::Types["params.nil"] | Dry::Types["string"]
  property :citation, on: :work_version
  property :default_citation, virtual: true, default: true
  property :citation_auto, virtual: true
  property :collection_id, on: :work
  property :access, on: :work_version
  property :license, on: :work_version
  property :agree_to_terms, on: :work_version
  property :created_type, virtual: true, prepopulator: (proc do |*|
    self.created_type = created_edtf.is_a?(EDTF::Interval) ? "range" : "single" unless created_type
  end)
  property :created_edtf, edtf: true, range: true, on: :work_version
  property :published_edtf, edtf: true, on: :work_version
  property :release, virtual: true, prepopulator: (proc do |*|
    self.release = embargo_date.present? ? "embargo" : "immediate" if release.blank?
  end)
  property :embargo_date, embargo_date: true, on: :work_version
  property :assign_doi, on: :work, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  property :upload_type, on: :work_version
  property :globus_origin, on: :work_version
  property :fetch_globus_files, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]

  validates_with EmbargoDateParts,
    if: proc { |form| form.user_can_set_availability? && form.release == "embargo" }

  validates_with CreatedDateParts, if: proc { |form| form.created_type == "range" }

  validates :subtype, work_subtype: true
  validates :work_type, presence: true, work_type: true
  validate :unique_filenames
  validate :globus_files_provided, if: proc { |form| form.fetch_globus_files }

  delegate :user_can_set_availability?, to: :collection

  def deserialize!(params)
    # Choose between using the user provided citation and the auto-generated citation
    params["citation"] = params.delete("citation_auto") if params["default_citation"] == "true"
    params["subtype"] = [] unless params["subtype"]
    deserialize_embargo(params)
    access_from_collection(params)
    deserialize_license(params)
    super(params)
  end

  # Ensure the collection default overwrites whatever the user supplied
  def deserialize_embargo(params)
    case collection.release_option
    when "delay"
      release_date = collection.release_date
      params["embargo_date(1i)"] = release_date.year.to_s
      params["embargo_date(2i)"] = release_date.month.to_s
      params["embargo_date(3i)"] = release_date.day.to_s
    when "immediate"
      params["embargo_date(1i)"] = nil
      params["embargo_date(2i)"] = nil
      params["embargo_date(3i)"] = nil
    end
  end

  # ensure all attached files have a unique filename
  def unique_filenames
    filenames = attached_files.map { |file| file.model.path }

    errors.add(:attached_files, "must all have a unique filename.") unless filenames.size == filenames.uniq.size
  end

  # Ensure there is more than zero files if fetching from Globus
  def globus_files_provided
    return if GlobusClient.has_files?(path: work_version.globus_endpoint, user_id: work.owner.email)

    errors.add(
      :attached_files,
      "must include at least one file uploaded to Globus at #{work_version.globus_endpoint_fullpath}"
    )
  rescue => e
    Honeybadger.notify(
      "Globus API Error",
      context: {
        exception: e,
        work_owner: work.owner.email,
        work_id: work.id,
        work_version: work_version.version
      }
    )
    errors.add(
      :attached_files,
      "encountered an error with the Globus API: #{e}"
    )
  end

  def access_from_collection(params)
    return if collection.access == "depositor-selects"

    params["access"] = collection.access
  end

  # Ensure the collection's required license overwrites whatever the user supplied
  def deserialize_license(params)
    return unless collection.required_license

    params["license"] = collection.required_license
  end

  # has_contributors(validate: false)

  collection :attached_files,
    populator: AttachedFilesPopulator.new(:attached_files, AttachedFile),
    on: :work_version do
    property :id, type: Dry::Types["params.nil"] | Dry::Types["params.integer"]
    property :label
    property :path
    property :hide, type: Dry::Types["params.bool"]
    # The file property is only necessary if there is a server side validation error and we need to re-render the form.
    property :file, virtual: true
    property :_destroy, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  end

  collection :contact_emails, populator: ContactEmailsPopulator.new(:contact_emails, ContactEmail),
    prepopulator: ->(*) { contact_emails << ContactEmail.new if contact_emails.blank? },
    on: :work_version do
    property :id, type: Dry::Types["params.nil"] | Dry::Types["params.integer"]
    property :email
    property :_destroy, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  end

  collection :keywords,
    populator: KeywordsPopulator.new(:keywords, Keyword),
    prepopulator: ->(*) { keywords << Keyword.new if keywords.blank? },
    on: :work_version do
    property :id, type: Dry::Types["params.nil"] | Dry::Types["params.integer"]
    property :label
    property :uri
    property :cocina_type
    property :_destroy, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  end

  collection :related_works,
    populator: RelatedWorksPopulator.new(:related_works, RelatedWork),
    prepopulator: ->(*) { related_works << RelatedWork.new if related_works.blank? },
    on: :work_version do
    property :id, type: Dry::Types["params.nil"] | Dry::Types["params.integer"]
    property :citation
    property :_destroy, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  end

  collection :related_links, populator: RelatedLinksPopulator.new(:related_links, RelatedLink),
    prepopulator: ->(*) { related_links << RelatedLink.new if related_links.blank? },
    on: :work_version do
    property :id, type: Dry::Types["params.nil"] | Dry::Types["params.integer"]
    property :link_title
    property :url
    property :_destroy, virtual: true, type: Dry::Types["params.nil"] | Dry::Types["params.bool"]
  end

  delegate :collection, :persisted?, :to_param, to: :work

  def work
    model[:work]
  end

  def work_version
    model[:work_version]
  end

  def version_description
    return if work_version.deposited?

    super
  end

  # Wrap the entire operation (root model and nested model save) in a transaction.
  # See https://github.com/apotonick/disposable/blob/v0.5.0/lib/disposable/twin/save.rb#L11
  def save!(*)
    Work.transaction do
      super
    end
  end

  # Ensure this work version is now head of the work versions for this work, and perform post save cleanup
  def save_model
    super
    # For a zipfile, both the existing files and the zipfile will be attached. These will be removed during unzip.
    dedupe_keywords
    work.update(head: work_version)
  end

  # Override reform so that this looks just like a Work
  def model_name
    Work.model_name
  end

  def will_assign_doi?
    (collection.doi_option == "depositor-selects" && assign_doi) || collection.doi_option == "yes"
  end

  # de-dupe keywords, prefer throwing away the free text entry duplicate(s) without a URI
  def dedupe_keywords
    return if work_version.keywords.empty?

    grouped_keywords = Keyword.where(work_version:).group_by(&:label) # group keywords by label for determining dupes
    grouped_keywords.each_value do |group|
      next if group.size == 1 # skip this group if there is only one keyword (no dupes!)

      duped_keywords = group.sort_by(&:uri) # this sorts the group, putting any with URIs at the end of the array
      duped_keywords.pop # this gets rid of last entry in the group, which is any duped keyword that may have a URI
      duped_keywords.each(&:destroy) # now destroy the rest of the dupes in the database
    end
  end
end
