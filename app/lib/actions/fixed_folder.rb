# frozen_string_literal: true

module Actions
  class FixedFolder
    def initialize(folder_name)
      @folder_name = folder_name
    end

    def update!
      puts "." * 50
      find_tags

      Actions::CleanedFolder.new(folder_name).update!
      cleaned_features = Actions::CleanedFeatures.new(folder_name, tags)
      cleaned_features.update! if artist && tags.artist_has_features

      move_folders = Actions::MoveFolders.new(folder_name, cleaned_features.common_artists_string, album)
      return unless validate!(move_folders)

      move_folders.update!
    end

    private

    attr_reader :folder_name, :artist, :album, :tags

    def validate!(move_folders)
      # assumes 1 folder = 1 album by 1 artist
      # TODO: handle multiple albums/artists, not sure how though :<
      # TODO: check coverage
      # TODO: rubocop
      # TODO: CI
      return abort("multiple albums in folder".red) unless album
      return abort("multiple artists in folder".red) unless artist
      return abort("there are files before mp3 directory".red) unless move_folders.src_directory
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
  end
end
