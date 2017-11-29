class CleanedFolder
  def initialize(folder_name)
    @folder_name = folder_name
  end

  def update!
    puts folder_name
  end

  private

  attr_reader :folder_name
end