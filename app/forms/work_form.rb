# typed: false
# frozen_string_literal: true

require 'reform/form/coercion'

class WorkForm < Reform::Form
  feature Coercion

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

  property 'created(1i)', virtual: true
  property 'created(2i)', virtual: true
  property 'created(3i)', virtual: true
  property 'created_range(1i)', virtual: true
  property 'created_range(2i)', virtual: true
  property 'created_range(3i)', virtual: true
  property 'created_range(4i)', virtual: true
  property 'created_range(5i)', virtual: true
  property 'created_range(6i)', virtual: true
  property 'published(1i)', virtual: true
  property 'published(2i)', virtual: true
  property 'published(3i)', virtual: true
  property :creation_type, virtual: true, default: 'single'

  def sync(*)
    model.created_edtf = case creation_type
                         when 'range'
                           deserialize_edtf_range(:created_range)
                         else
                           deserialize_edtf(:created)
                         end

    model.published_edtf = deserialize_edtf(:published)

    super
  end

  validates :title, presence: true

  collection :contributors,
             populator: lambda { |fragment:, **|
               # The fragment represents one row of the contributor data from the HTML form
               # find out if incoming Contributor is already added.
               item = contributors.find_by(id: fragment['id']) if fragment['id'].present?

               if fragment['_destroy'] == '1'
                 contributors.delete(item)
                 return skip!
               elsif fragment['first_name'].blank?
                 return skip!
               end
               item || contributors.append(Contributor.new)
             } do
    property :id
    property :first_name
    property :last_name
    property :role_term
    property :_destroy, virtual: true
  end

  collection :attached_files,
             populator: lambda { |fragment:, **|
               # The fragment represents one row of the attached file data from the HTML form
               # find out if incoming file is already added.
               item = attached_files.find_by(id: fragment['id']) if fragment['id'].present?

               if fragment['_destroy'] == '1'
                 attached_files.delete(item)
                 return skip!
               end
               item || attached_files.append(AttachedFile.new)
             } do
    property :id
    property :label
    property :hide
    property :file
    property :_destroy, virtual: true
  end

  private

  def deserialize_edtf(name, offset = 0)
    year = public_send("#{name}(#{offset + 1}i)")
    month = public_send("#{name}(#{offset + 2}i)")
    day = public_send("#{name}(#{offset + 3}i)")
    deserialize_edtf_date(year, month, day)
  end

  def deserialize_edtf_range(name)
    start = deserialize_edtf(name)
    finish = deserialize_edtf(name, 3)
    return unless start && finish

    # Slash is the range separator in EDTF
    [start, finish].join('/')
  end

  def deserialize_edtf_date(year, month, day)
    return if year.blank?

    date = year.dup
    if month.present?
      date += "-#{format('%<month>02d', month: month)}"
      date += "-#{format('%<day>02d', day: day)}" if day.present?
    end
    date
  end
end
