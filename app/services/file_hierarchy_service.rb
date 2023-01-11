# frozen_string_literal: true

# Arranges Attached Files into a hierarchy of directories and files.
class FileHierarchyService
  File = Struct.new(:attached_file) do
    def file?
      true
    end

    def directory?
      false
    end
  end

  Directory = Struct.new(:name, :children_directories, :children_files, :index) do
    def file?
      false
    end

    def directory?
      true
    end
  end

  def self.to_hierarchy(work_version:)
    new(work_version:).to_hierarchy
  end

  def initialize(work_version:)
    @work_version = work_version
    @root_directory = Directory.new('', [], [], 0)
  end

  def to_hierarchy
    work_version.attached_files.sort_by(&:filename).each { |attached_file| add_to_hierarchy(attached_file) }
    root_directory
  end

  private

  attr_reader :work_version, :root_directory

  def add_to_hierarchy(attached_file)
    directory = directory_for(attached_file.paths, root_directory)
    directory.children_files << File.new(attached_file)
  end

  def directory_for(paths, directory)
    return directory if paths.empty?

    path = paths.shift
    child_directory = directory.children_directories.find { |cd| cd.name == path }
    unless child_directory
      child_directory = Directory.new(path, [], [], directory.index + 1)
      directory.children_directories << child_directory
    end

    return child_directory if paths.empty?

    directory_for(paths, child_directory)
  end
end
