class FileList
  class << self
    def files(dir)
      files_and_folders(dir).select { |file| File.file? file }
    end

    private

    def files_and_folders(dir)
      Dir.glob("#{bash_escape(dir)}/**/*")
    end

    def bash_escape(dir)
      dir.gsub(/[\\\{\}\[\]\*\?]/) { |symbol| "\\#{symbol}" }
    end
  end
end