# frozen_string_literal: true

require 'bundler/setup'
Bundler.require

Dir["#{File.dirname(__FILE__)}/../app/lib/**/*.rb"].each {|file| require file } # require lib/*

RSpec.configure do |config|
  config.mock_with :mocha
end
