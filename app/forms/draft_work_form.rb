# typed: false
# frozen_string_literal: true

require 'reform/form/coercion'

# The form for draft work creation and editing
# rubocop:disable Metrics/ClassLength
class DraftWorkForm < Reform::Form
  feature Edtf

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
  property 'embargo_date(1i)', virtual: true, type: ::Types::Custom::NilableInteger
  property 'embargo_date(2i)', virtual: true, type: ::Types::Custom::NilableInteger
  property 'embargo_date(3i)', virtual: true, type: ::Types::Custom::NilableInteger

  validates :created_edtf, created_in_past: true
  validates :published_edtf, created_in_past: true

  def sync(*)
    model.embargo_date = deserialize_date(:embargo_date) if release == 'embargo'

    super
  end

  collection :contributors,
             populator: lambda { |fragment:, **|
               # The fragment represents one row of the contributor data from the HTML form
               # find out if incoming Contributor is already added.
               item = contributors.find_by(id: fragment['id']) if fragment['id'].present?

               if fragment['_destroy'] == '1'
                 contributors.delete(item)
                 return skip!
               elsif fragment['first_name'].blank? && fragment['full_name'].blank?
                 return skip!
               end

               # Clear out names that we don't want to store (e.g. first & last name for an organization)
               # These can get submitted to the server if the user enters a person
               # name and then switches the type/role to an organization name.
               if fragment['role_term'].start_with?('person')
                 fragment['full_name'] = nil
               else
                 fragment['first_name'] = nil
                 fragment['last_name'] = nil
               end
               item || contributors.append(Contributor.new)
             },
             prepopulator: ->(*) { contributors << Contributor.new } do
    property :id
    property :first_name
    property :last_name
    property :full_name
    property :role_term
    property :_destroy, virtual: true
  end

  collection :attached_files,
             populator: lambda { |fragment:, **|
               # The fragment represents one row of the attached file data from the HTML form
               # find out if incoming file is already added.
               item = attached_files.find_by(id: fragment['id']) if fragment['id'].present?

               if fragment['_destroy'] == '1'
                 # Remove AttachedFile and associated AS model instances if AF exists
                 # Else, there is no AF, so remove the AS::Blob directly
                 if item
                   attached_files.delete(item)
                 else
                   ActiveStorage::Blob.find_signed(fragment['file']).purge_later
                 end
                 return skip!
               end
               return item if item

               attached_files.append(AttachedFile.new(file: fragment['file']))
             } do
    property :id
    property :label
    property :hide
    # The file property is virtual so it doesn't get set on update, which causes:
    # ArgumentError: Could not find or build blob
    # So we set it manually when creating.
    property :file, virtual: true
    property :_destroy, virtual: true
  end

  collection :keywords,
             populator: lambda { |fragment:, **|
               # The fragment represents one row of the attached file data from the HTML form
               # find out if incoming file is already added.
               item = keywords.find_by(id: fragment['id']) if fragment['id'].present?

               if fragment['_destroy'] == '1'
                 keywords.delete(item)
                 return skip!
               end
               item || keywords.append(Keyword.new)
             } do
    property :id
    property :label
    property :uri
    property :_destroy, virtual: true
  end

  collection :related_works,
             populator: lambda { |fragment:, **|
               # The fragment represents one row of the attached file data from the HTML form
               # find out if incoming file is already added.
               item = related_works.find_by(id: fragment['id']) if fragment['id'].present?

               if fragment['_destroy'] == '1'
                 related_works.delete(item)
                 return skip!
               elsif fragment['citation'].blank?
                 return skip!
               end
               item || related_works.append(RelatedWork.new)
             },
             prepopulator: ->(*) { related_works << RelatedWork.new } do
    property :id
    property :citation
    property :_destroy, virtual: true
  end

  collection :related_links,
             populator: lambda { |fragment:, **|
               # The fragment represents one row of the attached file data from the HTML form
               # find out if incoming file is already added.
               item = related_links.find_by(id: fragment['id']) if fragment['id'].present?

               if fragment['_destroy'] == '1'
                 related_links.delete(item)
                 return skip!
               elsif fragment['url'].blank?
                 return skip!
               end
               item || related_links.append(RelatedLink.new)
             },
             prepopulator: ->(*) { related_links << RelatedLink.new } do
    property :id
    property :link_title
    property :url
    property :_destroy, virtual: true
  end

  private

  def deserialize_date(name)
    year = public_send("#{name}(1i)")
    month = public_send("#{name}(2i)")
    day = public_send("#{name}(3i)")
    Date.new(year, month, day)
  end
end
# rubocop:enable Metrics/ClassLength
