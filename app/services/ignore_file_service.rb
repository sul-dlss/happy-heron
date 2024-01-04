# frozen_string_literal: true

# Service for determining if a file provided by a user should be ignored.
class IgnoreFileService
  def self.ignore?(filename)
    filename.start_with?('__MACOSX', '._') \
    || File.basename(filename).start_with?('__MACOSX', '._') \
    || filename.end_with?('.DS_Store')
  end
end
