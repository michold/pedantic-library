# frozen_string_literal: true

class FixedFolder
  def initialize(folder_name)
    @folder_name = folder_name
  end

  def update!
    puts "." * 50
    find_tags

    CleanedFolder.new(folder_name).update!
    CleanedFeatures.new(folder_name, tags).update! if artist && tags.artist_has_features

    return unless validate!

    move_folders.update!
  end

  private

  attr_reader :folder_name, :artist, :album, :tags

  def validate!
    # assumes 1 folder = 1 album by 1 artist
    # TODO: handle multiple albums/artists, not sure how though :<
    # TODO: check coverage
    # TODO: rubocop
    # TODO: CI
    return abort("multiple albums in folder".red) unless album
    return abort("multiple artists in folder".red) unless artist

    return abort("there are files before mp3 directory".red) unless src_directory
    return abort("files are sorted properly".green) if same_path?(src_directory, destination_directory)
    return abort unless approved_by_prompt("move files from `#{folder_name}` to `#{destination_directory}`")
    true
  end

  def abort(reason = nil)
    message = "aborting update of folder `#{folder_name}`"
    message += " due to #{reason}" if reason
    puts message
    false
  end

  def approved_by_prompt(message)
    # TODO: make it a separate class
    puts "This script will #{message}"
    puts "Do you want to continue? (y/n)"
    gets.chomp == "y"
  end

  def find_tags
    @tags = FileTags.new(folder_name)

    @artist = tags.artists.uniq.length == 1 && tags.artists[0]
    @album = tags.albums.uniq.length == 1 && tags.albums[0]
  end

  def move_folders
    MoveFolders.new(folder_name, artist, album)
  end

  def src_directory
    move_folders.src_directory
  end

  def destination_directory
    move_folders.destination_directory
  end

  def same_path?(path1, path2)
    path1.downcase == path2.downcase
  end
end
