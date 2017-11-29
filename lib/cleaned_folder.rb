class CleanedFolder
  def initialize(folder_name)
    @folder_name = folder_name
    @artists = []
    @albums = []
  end

  def update!
    # assumes 1 folder = 1 album
    # TODO: handle multiple albums, not sure how though :<
    scan_files_tags

    artist = artists.uniq.length == 1 && artists[0]
    album = albums.uniq.length == 1 && albums[0]

    return unless artist && album

    puts '.....'
    puts artist
    puts '.....'
    puts album
    puts '.....'
  end

  private

  attr_reader :folder_name, :artists, :albums

  def scan_files_tags
    mp3_files.each do |file_path|
      ID3Tag.read(File.open(file_path)) do |tag|
        artists << find_artist(tag)
        albums << find_album(tag)
      end
    end
  end

  def find_artist(tag)
    begin
      tag.artist
    rescue ID3Tag::Tag::MultipleFrameError
      last_hope(tag, :TIT2)
    end
  end

  def find_album(tag)
    begin
      tag.album
    rescue ID3Tag::Tag::MultipleFrameError
      last_hope(tag, :TIT2)
    end
  end

  def last_hope(tag, id)
    frames = tag.all_frames_by_id(id)
    results = frames.map(&:content).uniq
    results.length == 1 ? results[0] : (raise D3Tag::Tag::MultipleFrameError)
  end

  def files
    @_files ||= Dir.glob("#{bash_escape(folder_name)}/**/*")
  end

  def bash_escape(string)
    string.gsub(/[\\\{\}\[\]\*\?]/) { |symbol| "\\#{symbol}" }
  end

  def mp3_files
    files.find_all do |file|
      file.end_with? '.mp3'
    end
  end
end