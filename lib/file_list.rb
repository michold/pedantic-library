class FileList
  MUSIC_EXTENSIONS = ['mp3'] # TODO: handle flacs, aac 

  def initialize(dir)
    @dir = dir
  end

  def all_files
    files
  end

  def music_files
    files.find_all { |file_name| music_file?(file_name) }
  end

  private

  attr_reader :dir

  def files
    @_files ||= files_and_folders.select { |file| File.file? file }
  end

  def files_and_folders
    Dir.glob("#{bash_escaped_dir}/**/*")
  end

  def bash_escaped_dir
    dir.gsub(/[\\\{\}\[\]\*\?]/) { |symbol| "\\#{symbol}" }
  end

  def music_file?(file_name)
    MUSIC_EXTENSIONS.any? do |ext|
      file_name.end_with? ".#{ext}"
    end
  end
end