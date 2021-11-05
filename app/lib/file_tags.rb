class FileTags
  attr_reader :artists, :albums, :artist_has_features, :files

  def initialize(folder_name)
    @folder_name = folder_name
    # TODO: sometimes artist and album tags are mixed up
    @artists = []
    @artist_has_features = false
    @albums = []
    @files = []
    scan_files_tags
  end

  private

  attr_reader :folder_name

  def scan_files_tags
    music_files.each do |file_path|
      ID3Tag.read(File.open(file_path)) do |tag|
        artist = find_artist(tag)
        album = find_album(tag)

        artists << artist
        albums << album
        files << { artist: artist, file_path: file_path, album: album, title: tag.title }
      end
    end

    cleanup_artists
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
    results.length == 1 ? results[0] : (raise ID3Tag::Tag::MultipleFrameError)
  end

  def music_files
    FileList.new(folder_name).music_files
  end

  def cleanup_artists
    @artists = artists.map do |artist|
      next artist unless artist.is_a?(String)

      first_artist = artist.split(CleanedFeatures::FEATURES_SEPARATOR).first
      next artist if artist == first_artist
      @artist_has_features = true

      next first_artist
    end
  end
end
