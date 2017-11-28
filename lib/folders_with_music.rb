class FoldersWithMusic
  MUSIC_EXTENSIONS = ['mp3', 'flac'] 

  def initialize(cwd)
    @cwd = cwd
  end

  def names
    Dir.entries(cwd).find_all do |dir|
      folder_with_music?(dir)
    end
  end

  private

  attr_reader :cwd

  def folder_with_music?(dir)
    !recursive?(dir) && folder?(dir) && has_music?(dir)
  end

  def recursive?(dir)
    dir == '.' || dir == '..'
  end

  def folder?(dir)
    File.directory? dir
  end

  def has_music?(dir)
    files = Dir.glob("#{bash_escape(dir)}/**/*")
    files.any? { |file_name| music_file?(file_name)  }
  end

  def music_file?(file_name)
    MUSIC_EXTENSIONS.any? do |ext|
      file_name.end_with? ".#{ext}"
    end
  end

  def bash_escape(string)
    string.gsub(/[\\\{\}\[\]\*\?]/) { |symbol| "\\#{symbol}" }
  end
end