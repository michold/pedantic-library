# frozen_string_literal: true

require 'bundler/setup' 
Bundler.require

DEFAULT_LOCATION = "/Users/#{ENV['USER']}/Desktop/"
CWD = ARGV[0] || DEFAULT_LOCATION
MUSIC_EXTENSIONS = ['mp3', 'flac'] 

def main
  Dir.chdir CWD
  Dir.entries('./').each do |dir|
    next if skip_dir?(dir)
    puts dir
  end
end

def skip_dir?(dir)
  recursive?(dir) || file?(dir) || !has_music?(dir)
end

def recursive?(dir)
  dir == '.' || dir == '..'
end

def file?(dir)
  File.file? dir
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

main