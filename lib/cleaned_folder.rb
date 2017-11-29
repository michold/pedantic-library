class CleanedFolder
  def initialize(folder_name)
    @folder_name = folder_name
    @artists = []
    @albums = []
  end

  def update!
    find_tags
    # assumes 1 folder = 1 album
    # TODO: handle multiple albums, not sure how though :<
    return unless artist && album

    return unless approved_by_prompt

    fix_directories
  end

  private

  attr_reader :folder_name, :artist, :album

  def approved_by_prompt
    puts "This script will move files from `#{folder_name}` to `#{proper_directory}`"
    puts "Do you want to continue? (y/n)"
    gets.chomp == "y"
  end

  def proper_directory
    File.join(artist, album)
  end

  def fix_directories
    puts "mv rm mv rm"
    # move_files_to_temp
    # remove_old_folder
    # move_files_to_proper_folder
    # remove_temp_folder
  end

  def find_tags
    tags = FileTags.new(folder_name)

    @artist = tags.artists.uniq.length == 1 && tags.artists[0]
    @album = tags.albums.uniq.length == 1 && tags.albums[0]
  end

  def folders
    @_folders ||= Dir.glob("#{bash_escape(folder_name)}/**/*/")
  end

  def files
    @_files ||= Dir.glob("#{bash_escape(folder_name)}/**/*")
  end

  def bash_escape(string)
    string.gsub(/[\\\{\}\[\]\*\?]/) { |symbol| "\\#{symbol}" }
  end
end