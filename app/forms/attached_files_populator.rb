# typed: true
# frozen_string_literal: true

# Populates the nested attached files form
class AttachedFilesPopulator < ApplicationPopulator
  # The fragment represents one row of the attached file data from the HTML form
  # find out if incoming file is already added.
  def call(form, fragment:, **)
    item = existing_record(form: form, id: fragment['id'])

    if fragment['_destroy'] == '1'
      # Remove AttachedFile and associated AS model instances if AF exists
      # Else, there is no AF, so remove the AS::Blob directly
      if item
        form.attached_files.delete(item)
      else
        ActiveStorage::Blob.find_signed!(fragment['file']).purge_later
      end
      return skip!
    end
    item || form.attached_files.append(AttachedFile.new(file: fragment['file']))
  end
end
