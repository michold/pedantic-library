# frozen_string_literal: true

require 'bundler/setup'
Bundler.require
require 'taglib'

Dir["#{File.dirname(__FILE__)}/../app/lib/**/*.rb"].each {|file| require file } # require lib/*

# require 'fakefs' # needs to be added after loading files

RSPEC_ROOT = File.dirname __FILE__

RSpec.configure do |config|
  config.mock_with :mocha
  config.order = :random
end
