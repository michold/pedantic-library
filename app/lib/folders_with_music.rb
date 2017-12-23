class FoldersWithMusic
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
    FileList.new(dir).music_files.any?
  end
end