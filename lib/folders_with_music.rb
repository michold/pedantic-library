class FoldersWithMusic
  MUSIC_EXTENSIONS = ['mp3'] # TODO: handle flacs, aac 

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
    dir == '.' || dir == '..' || File.symlink?(dir) # TODO: rethink symlinks handling
  end

  def folder?(dir)
    File.directory? dir
  end

  def has_music?(dir)
    files(dir).any? { |file_name| music_file?(file_name) }
  end

  def files(dir)
    FileList.files(dir)
  end

  def music_file?(file_name)
    MUSIC_EXTENSIONS.any? do |ext|
      file_name.end_with? ".#{ext}"
    end
  end
end