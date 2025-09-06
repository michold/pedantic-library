# frozen_string_literal: true

module Actions
  class CleanedFeatures
    FEATURES_SEPARATOR = /;\s|,\s|\s\&\s/

    def initialize(folder_name, tags)
      @folder_name = folder_name
      @tags = tags
    end

    def update!
      tags.files.each do |file|
        artist = file.fetch(:artist)
        artists = artist.split(FEATURES_SEPARATOR)

        add_features_to_title(file.fetch(:artist), artists, common_artists_string, file.fetch(:title), file.fetch(:file_path))
      end
    end

    def common_artists_string
      @_common_artists_string ||= stringify_artists(common_artists)
    end

    private

    attr_reader :folder_name, :tags

    def common_artists
      @_common_artists ||= get_common_artists
    end

    def get_common_artists
      # if it's just one file, assume only first tagged artist matters
      return [tags.files.first.fetch(:artist).split(FEATURES_SEPARATOR).first] if tags.files.count == 1

      artist_map = tags.files.to_h do |file|
        artist = file.fetch(:artist)
        artists = artist.split(FEATURES_SEPARATOR) + get_title_features(file.fetch(:title))
        [file, artists.uniq]
      end

      artist_map.values.inject(&:&) || []
    end

    def add_features_to_title(org_artists_string, org_artists, common_artists_string, org_title, file_path)
      new_title = get_new_title(org_title, org_artists)
      return if new_title == org_title && common_artists == org_artists

      return unless Cli::Approval.get("change `#{org_title}` by `#{org_artists_string}` to `#{new_title}` by `#{common_artists_string}`")

      update_file(file_path, common_artists_string, new_title)
    end

    def update_file(file_path, artist, title)
      TagLib::MPEG::File.open(file_path) do |mp3_file|
        tag = mp3_file.id3v2_tag
        tag.artist = artist
        tag.title = title
        mp3_file.save
      end
    end

    def get_new_title(org_title, org_artists)
      title_matches = org_title.match(/(.*)\s\(feat\.\s(.*)\)/)
      title_features = get_title_features(org_title)
      featured_artists = (org_artists | title_features) - common_artists
      new_base_title = title_matches ? title_matches[1] : org_title

      return new_base_title if featured_artists.empty?

      "#{new_base_title} (feat. #{stringify_artists(featured_artists)})"
    end

    def get_title_features(title)
      title_matches = title.match(/(.*)\s\(feat\.\s(.*)\)/)
      title_matches ? title_matches[2].split(/\s\&\s|,\s/) : []
    end

    def stringify_artists(artists)
      result = artists.join(", ")
      result = result.sub(/.*\K,\ /, ' & ')
      result
    end
  end
end
