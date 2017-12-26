# frozen_string_literal: true

require 'bundler/setup'
Bundler.require

Dir["./#{File.dirname(__FILE__)}/lib/**/*.rb"].each {|file| require file } # require lib/*


Main.new(ARGV[0]).process
