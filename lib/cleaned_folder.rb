# frozen_string_literal: true

class CleanedFolder
  TEMP_DIR = "temp_#{Time.now.to_i}"

  def initialize(folder_name)
    @folder_name = folder_name
    @artists = []
    @albums = []
  end

  def update!
    puts "." * 50
    find_tags

    PreprocessedFolder.new(folder_name).update!

    return unless validate!

    fix_directories
  end

  private

  attr_reader :folder_name, :artist, :album

  def validate!
    # assumes 1 folder = 1 album by 1 artist
    # TODO: handle multiple albums/artists, not sure how though :<
    # TODO: TESTS :| 
    return abort("multiple albums in folder".red) unless album
    return abort("multiple artists in folder".red) unless artist

    return abort("there are files before mp3 directory".red) unless src_path
    return abort("files are sorted properly".green) if same_path(src_path, proper_directory)
    return abort unless approved_by_prompt
    true
  end

  def abort(reason = nil)
    message = "aborting update of folder `#{folder_name}`"
    message += " due to #{reason}" if reason
    puts message
  end

  def approved_by_prompt
    puts "This script will move files from `#{folder_name}` to `#{proper_directory}`"
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
      FileUtils.rm_f(folder_name) # delete old folder if artist folder already exists
    else
      File.rename(folder_name, artist) # rename old folder if artist folder doesn't exist yet
    end
  end

  def find_tags
    tags = FileTags.new(folder_name)

    @artist = tags.artists.uniq.length == 1 && tags.artists[0]
    @album = tags.albums.uniq.length == 1 && tags.albums[0]
  end

  def files
    @_files ||= Dir.glob("#{bash_escape(folder_name)}/**/*").select { |file| File.file? file }
  end

  def mp3_files
    files.find_all do |file|
      file.end_with? '.mp3'
    end
  end

  def bash_escape(string)
    string.gsub(/[\\\{\}\[\]\*\?]/) { |symbol| "\\#{symbol}" }
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

  def same_path(path1, path2)
    path1.downcase == path2.downcase
  end
end