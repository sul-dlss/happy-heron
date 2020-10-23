# typed: strict
# frozen_string_literal: true

class Work < ApplicationRecord
  extend T::Sig

  belongs_to :collection

  has_many :contributors, dependent: :destroy
  has_many :related_links, dependent: :destroy
  has_many :related_works, dependent: :destroy
  has_many_attached :files

  accepts_nested_attributes_for :contributors, allow_destroy: true, reject_if: :last_name_blank

  validates :abstract, :access, :citation, :state, :subtype, :title, presence: true
  validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :created_edtf, :published_edtf, edtf: true
  validates :license, presence: true, inclusion: { in: License.all.map(&:id) }
  validates :work_type, presence: true, inclusion: { in: WorkType.all.map(&:id) }

  enum access: {
    stanford: 'stanford',
    world: 'world'
  }

  state_machine initial: :first_draft do
    event :deposit do
      transition first_draft: :deposited, version_draft: :deposited
    end

    event :new_version do
      transition deposited: :version_draft
    end
  end

  sig { params(attr: T::Hash[String, String]).returns(T::Boolean) }
  def last_name_blank(attr)
    attr['last_name'].blank?
  end

  def published
    EDTF.parse(published_edtf) if published_edtf
  end

  def published=(date_parts)
    self.published_edtf = deserialize_edtf(date_parts)
  end

  def creation_type= val
    # TODO: ensure valid value
    @creation_type = val
  end

  def created=(date_parts)
    byebug
    self.created_edtf = deserialize_edtf(date_parts)
  end

  def created_range=(date_parts)
    byebug
    self.created_edtf = deserialize_edtf(date_parts)
  end


  private

  def deserialize_edtf(date_parts)
    date = date_parts[1].to_s
    if date_parts[2]
      date += "-#{"%02d" % date_parts[2]}"
      if date_parts[3]
        date += "-#{"%02d" % date_parts[3]}"
      end
    end
  end
end
