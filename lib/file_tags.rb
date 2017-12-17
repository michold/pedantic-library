class FileTags
  def initialize(folder_name)
    @folder_name = folder_name
    # TODO: get album artist with fallback to normal artist
    # TODO: sometimes artist and album tags are mixed up
    @artists = []
    @albums = []
    scan_files_tags
  end

  attr_reader :artists, :albums

  private

  attr_reader :folder_name

  def scan_files_tags
    mpusic_files.each do |file_path|
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

  def mpusic_files
    FileList.new(folder_name).music_files
  end
end