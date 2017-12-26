class Main
  DEFAULT_LOCATION = "/Users/#{ENV['USER']}/Desktop"

  def initialize(cwd)
    @cwd = cwd || DEFAULT_LOCATION
  end

  def process
    Dir.chdir cwd
    folders_to_check = FoldersWithMusic.new('./').names
    folders_to_check.each do |folder_name|
      CleanedFolder.new(folder_name).update!
    end
  end

  private

  attr_reader :cwd
end
