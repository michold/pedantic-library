# frozen_string_literal: true

module Actions
  class MoveFolders
    TEMP_DIR = "temp_#{Time.now.to_i}"

    def initialize(folder_name, artist, album)
      @folder_name = folder_name
      @artist = artist
      @album = album
    end

    def update!
      return abort("files are sorted properly".green) if same_path? && filepaths_are_only_ascii?

      return abort if !same_path? && !approved_by_prompt("move files from `#{folder_name}` to `#{destination_directory}`")

      puts "moving files to `#{destination_directory}`..." if same_path? # tell the user which album we're working on if they don't know yet

      move_files
    end

    def src_directory
      @_src_directory ||= find_src_path
    end

    private

    attr_reader :folder_name, :artist, :album

    def move_files
      FileUtils.cp_r(src_directory, TEMP_DIR) # copy music to temp
      FileUtils.rm_rf(File.join(folder_name, "."), secure: true) # remove content of old folder
      prepare_destination_folder
      move_files_to_new_folder
      FileUtils.rm_rf(TEMP_DIR, secure: true)
    end

    def prepare_destination_folder
      create_artist_folder
      Dir.mkdir(destination_directory)
    end

    def create_artist_folder
      return if folder_name == artist_folder_name

      if File.directory?(artist_folder_name)
        FileUtils.rm_rf(folder_name) # delete old folder if artist folder already exists
      else
        File.rename(folder_name, artist_folder_name) # rename old folder if artist folder doesn't exist yet
      end
    end

    def move_files_to_new_folder
      files.each do |file_path|
        file_name = File.basename(file_path)
        new_file_name = file_name.to_ascii
        if new_file_name != file_name
          new_file_name = file_name unless approved_by_prompt("rename file from `#{file_name}` to `#{new_file_name}`")
        end
        FileUtils.mv(File.join(TEMP_DIR, file_name), File.join(destination_directory, new_file_name)) # move temp as new folder's album
      end
    end

    def destination_directory
      File.join(artist_folder_name, album_folder_name)
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

    def find_src_path
      path = common_folder(files)
      path == common_folder(file_list.music_files) ? path : nil
    end

    def common_folder(paths)
      /\A(.*)\/.*(\n\1.*)*\Z/.match(paths.join("\n"))[1] # regex magic
    end

    def abort(reason = nil)
      message = "aborting update of folder `#{folder_name}`"
      message += " due to #{reason}" if reason
      puts message
    end

    def approved_by_prompt(message)
      puts "This script will #{message}"
      puts "Do you want to continue? (y/n)"
      gets.chomp == "y"
    end

    def filepaths_are_only_ascii?
      files.map(&:to_ascii) == files
    end

    def same_path?
      src_directory == destination_directory
    end
  end
end
