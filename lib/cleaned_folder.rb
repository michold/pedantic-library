class CleanedFolder
  def initialize(folder_name)
    @folder_name = folder_name
    @artists = []
    @albums = []
  end

  def update!
    puts "." * 50
    find_tags
    # assumes 1 folder = 1 album by 1 artist
    # TODO: handle multiple albums/artists, not sure how though :<
    return abort("multiple albums in folder") unless album
    return abort("multiple artists in folder") unless artist

    return abort unless approved_by_prompt

    fix_directories
  end

  private

  attr_reader :folder_name, :artist, :album

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
    puts "mv rm"
    # get directory of mp3s [and scans and all] 

    # def common_prefix(paths)
    #   return '' if paths.empty?
    #   return paths.first.split('/').slice(0...-1).join('/') if paths.length <= 1
    #   arr = paths.sort
    #   first = arr.first.split('/')
    #   last = arr.last.split('/')
    #   i = 0
    #   i += 1 while first[i] == last[i] && i <= first.length
    #   first.slice(0, i).join('/')
    # end

    # -> check if all mp3s are in 'common_prefix'

    # move_files_to_proper_folder
    # remove_old_folders
  end

  def find_tags
    tags = FileTags.new(folder_name)

    @artist = tags.artists.uniq.length == 1 && tags.artists[0]
    @album = tags.albums.uniq.length == 1 && tags.albums[0]
  end

  def files
    @_files ||= Dir.glob("#{bash_escape(folder_name)}/**/*")
  end

  def bash_escape(string)
    string.gsub(/[\\\{\}\[\]\*\?]/) { |symbol| "\\#{symbol}" }
  end
end