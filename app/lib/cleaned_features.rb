# frozen_string_literal: true

class CleanedFeatures
  def initialize(folder_name, tags)
    @folder_name = folder_name
    @tags = tags
  end

  def update!
    tags.files.each do |file|
      artist = file.fetch(:artist)
      artists = artist.split(/;\s|\s\&\s/)
      next if artists.length == 1

      add_features_to_title(file.fetch(:artist), artists, file.fetch(:title), file.fetch(:file_path))
    end
  end

  private

  attr_reader :folder_name, :tags

  def add_features_to_title(org_artist, artists, title, file_path)
    ID3Tag.read(File.open(file_path)) do |tag|
      artist = artists.delete_at(0)
      new_title = get_new_title(title, artists)
      return unless approved_by_prompt("change `#{title}` by `#{org_artist}` to `#{new_title}` by `#{artist}`")

      update_file(file_path, artist, new_title)
    end
  end

  def update_file(file_path, artist, title)
    TagLib::MPEG::File.open(file_path) do |mp3_file|
      tag = mp3_file.id3v2_tag
      tag.artist = artist
      tag.title = title
      mp3_file.save
    end
  end

  def get_new_title(title, artists)
    title_matches = title.match(/(.*)\s\(feat\.\s(.*)\)/)
    title_features = title_matches ? title_matches[2].split(/\s\&\s|,\s/) : []
    new_base_title = title_matches ? title_matches[1] : title
    "#{new_base_title} (feat. #{features_string(title_features | artists)})"
  end

  def features_string(features)
    result = features.join(", ")
    result = result.sub(/.*\K,\ /, ' & ')
    result
  end

  def approved_by_prompt(message)
    puts "This script will #{message}"
    puts "Do you want to continue? (y/n)"
    gets.chomp == "y"
  end
end
