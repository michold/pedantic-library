# frozen_string_literal: true

require 'bundler/setup'
Bundler.require
require 'taglib'

Dir["./#{File.dirname(__FILE__)}/lib/**/*.rb"].each {|file| require file }


Main.new(ARGV[0]).process
