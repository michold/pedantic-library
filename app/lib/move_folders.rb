# frozen_string_literal: true

class MoveFolders
  TEMP_DIR = "temp_#{Time.now.to_i}"

  def initialize(folder_name, artist, album)
    @folder_name = folder_name
    @artist = artist
    @album = album
  end

  def update!
    FileUtils.cp_r(src_directory, TEMP_DIR) # copy music to temp
    FileUtils.rm_rf(File.join(folder_name, "."), secure: true) # remove content of old folder
    prepare_new_folder
    files.each do |file_path|
      file_name = File.basename(file_path)
      FileUtils.mv(File.join(TEMP_DIR, file_name), File.join(destination_directory, file_name.to_ascii)) # move temp as new folder's album
    end
  end

  def destination_directory
    File.join(artist_folder_name, album_folder_name)
  end

  def src_directory
    @_src_directory ||= find_src_path
  end

  private

  attr_reader :folder_name, :artist, :album

  def prepare_new_folder
    return if folder_name == artist_folder_name
    if File.directory?(artist_folder_name)
      FileUtils.rm_rf(folder_name) # delete old folder if artist folder already exists
    else
      File.rename(folder_name, artist_folder_name) # rename old folder if artist folder doesn't exist yet
    end
    Dir.mkdir(destination_directory)
  end

  def album_folder_name
    @_album_folder_name ||= album.to_ascii
  end

  def artist_folder_name
    @_artist_folder_name ||= artist.to_ascii
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

  def find_src_path
    path = common_folder(files)
    path == common_folder(mp3_files) ? path : nil
  end

  def common_folder(paths)
    /\A(.*)\/.*(\n\1.*)*\Z/.match(paths.join("\n"))[1] # regex magic
  end
end
