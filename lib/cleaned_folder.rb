class CleanedFolder
  def initialize(folder_name)
    @folder_name = folder_name
    @artists = []
    @albums = []
  end

  def update!
    # assumes 1 folder = 1 album
    # TODO: handle multiple albums, not sure how though :<
    find_tags

    return unless artist && album

    puts '.....'
    puts artist
    puts '.....'
    puts album
    # puts files
    puts folders
    puts '.....'
  end

  private

  attr_reader :folder_name, :artist, :album

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