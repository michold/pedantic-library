# frozen_string_literal: true

class CleanedFolder
  TO_REMOVE = [
    '.DS_STORE',
    '*.dat',
    'Thumbs.db'
  ].freeze

  def initialize(folder_name)
    @folder_name = folder_name
  end

  def update!
    return if files_to_remove.empty?
    return abort unless approved_by_prompt
    files_to_remove.each { |file| File.delete(file) }
  end

  private

  attr_reader :folder_name

  def approved_by_prompt
    puts "This script will remove the following files:"
    puts files_to_remove
    puts "From #{folder_name} directory."
    puts "Do you want to continue? (y/n)"
    gets.chomp == "y"
  end

  def abort
    puts "aborting delete of files in folder `#{folder_name}`"
  end

  def files_to_remove
    @_files_to_remove ||= find_files_to_remove
  end

  def find_files_to_remove
    TO_REMOVE.map do |pattern|
      files_with_pattern(pattern)
    end.flatten
  end

  def files_with_pattern(pattern)
    Dir.glob(File.join(folder_name, '**', pattern))
  end
end
