# frozen_string_literal: true

require 'bundler/setup' 
Bundler.require
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file } # require /lib/*

DEFAULT_LOCATION = "/Users/#{ENV['USER']}/Desktop/"
CWD = ARGV[0] || DEFAULT_LOCATION

def main
  folders_to_check = FoldersWithMusic.new(CWD).names
  puts folders_to_check
end

main