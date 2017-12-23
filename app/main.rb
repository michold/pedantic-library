# frozen_string_literal: true

require 'bundler/setup'
Bundler.require

Dir["./#{File.dirname(__FILE__)}/lib/*.rb"].each {|file| require file } # require lib/*

DEFAULT_LOCATION = "/Users/#{ENV['USER']}/Desktop"
CWD = ARGV[0] || DEFAULT_LOCATION

def main
  Dir.chdir CWD
  folders_to_check = FoldersWithMusic.new('./').names
  folders_to_check.each do |folder_name|
    CleanedFolder.new(folder_name).update!
  end
end

main
