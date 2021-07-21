# frozen_string_literal: true

require 'bundler/setup'
Bundler.require

Dir["#{File.dirname(__FILE__)}/../app/lib/**/*.rb"].each {|file| require file } # require lib/*

require 'fakefs' # needs to be added after loading files

RSpec.configure do |config|
  config.mock_with :mocha
  config.order = :random
end
