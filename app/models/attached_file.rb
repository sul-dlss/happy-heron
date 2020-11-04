# typed: false
# frozen_string_literal: true

# Models a File that is attached to a Work
class AttachedFile < ApplicationRecord
  belongs_to :work
  has_one_attached :file

  def blob
    file.attachment.blob
  end

  delegate :filename, :content_type, :byte_size, to: :blob
end
