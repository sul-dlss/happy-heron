# typed: true
# frozen_string_literal: true

# Populates the nested attached files form
class AttachedFilesPopulator < ApplicationPopulator
  # The fragment represents one row of the attached file data from the HTML form
  # find out if incoming file is already added.
  def call(form, fragment:, **)
    item = existing_record(form: form, id: fragment['id'])

    if fragment['_destroy'] == '1'
      # Remove AttachedFile and associated ActiveStorage objects
      form.attached_files.delete(item) if item
      return skip!
    end
    return item if item

    # When in the ValidationController, sometimes fragment['file'] is an empty string. Avoid trying to load that.
    return skip! if fragment['file'].blank?

    form.attached_files.append(AttachedFile.new(file: fragment['file']))
  end
end
