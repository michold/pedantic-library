# frozen_string_literal: true

class FixedFolder
  TEMP_DIR = "temp_#{Time.now.to_i}"

  def initialize(folder_name)
    @folder_name = folder_name
    @artists = []
    @albums = []
  end

  def update!
    puts "." * 50
    puts folder_name
    find_tags

    CleanedFolder.new(folder_name).update!
    CleanedFeatures.new(folder_name, tags).update! if artist && tags.artist_has_features

    return unless validate!

    fix_directories
  end

  private

  attr_reader :folder_name, :artist, :album, :tags

  def validate!
    # assumes 1 folder = 1 album by 1 artist
    # TODO: handle multiple albums/artists, not sure how though :<
    # TODO: TESTS :|
    # TODO: check coverage
    # TODO: CI
    return abort("multiple albums in folder".red) unless album
    return abort("multiple artists in folder".red) unless artist

    return abort("there are files before mp3 directory".red) unless src_path
    return abort("files are sorted properly".green) if same_path?(src_path, proper_directory)
    return abort unless approved_by_prompt("move files from `#{folder_name}` to `#{proper_directory}`")
    true
  end

  def abort(reason = nil)
    message = "aborting update of folder `#{folder_name}`"
    message += " due to #{reason}" if reason
    puts message
  end

  def approved_by_prompt(message)
    # TODO: make it a separate class
    puts "This script will #{message}"
    puts "Do you want to continue? (y/n)"
    gets.chomp == "y"
  end

  def proper_directory
    File.join(artist, album)
  end

  def fix_directories
    FileUtils.cp_r(src_path, TEMP_DIR) # copy music to temp
    FileUtils.rm_rf(File.join(folder_name, "."), secure: true) # remove content of old folder
    handle_old_folder
    FileUtils.mv(TEMP_DIR, proper_directory) # move temp as new folder's album
  end

  def handle_old_folder
    return if folder_name == artist
    if File.directory?(artist)
      FileUtils.rm_rf(folder_name) # delete old folder if artist folder already exists
    else
      File.rename(folder_name, artist) # rename old folder if artist folder doesn't exist yet
    end
  end

  def find_tags
    @tags = FileTags.new(folder_name)

    @artist = tags.artists.uniq.length == 1 && tags.artists[0]
    @album = tags.albums.uniq.length == 1 && tags.albums[0]
  end

  def file_list
    @_file_list ||= FileList.new(folder_name)
  end

  def files
    @_files ||= file_list.all_files
  end

  def mp3_files
    @_mp3_files ||= file_list.music_files
  end

  def common_folder(paths)
    /\A(.*)\/.*(\n\1.*)*\Z/.match(paths.join("\n"))[1] # regex magic
  end

  def src_path
    @_src_path ||= find_src_path
  end

  def find_src_path
    path = common_folder(files)
    path == common_folder(mp3_files) ? path : nil
  end

  def same_path?(path1, path2)
    path1.downcase == path2.downcase
  end
end
